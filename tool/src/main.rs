//! A utility for automating various CI/CD activities for the Tectonic project
//! across different platforms.

use failure::{format_err, Error};
use json::object;
use std::{env, fs::File, path::PathBuf};
use structopt::StructOpt;

fn maybe_var(key: &str) -> Result<Option<String>, Error> {
    if let Some(os_str) = env::var_os(key) {
        if let Ok(s) = os_str.into_string() {
            if s.len() > 0 {
                Ok(Some(s))
            } else {
                Ok(None)
            }
        } else {
            Err(format_err!(
                "could not parse environment variable {} into Unicode",
                key
            ))
        }
    } else {
        Ok(None)
    }
}

fn require_var(key: &str) -> Result<String, Error> {
    maybe_var(key)?.ok_or_else(|| format_err!("environment variable {} must be provided", key))
}

struct GitHubInformation {
    commit_sha: String,
    slug: String,
    tag: String,
    token: String,
}

impl GitHubInformation {
    fn new() -> Result<Self, Error> {
        let token = require_var("GITHUB_TOKEN")?;

        let info = if let Some(tag) = maybe_var("TRAVIS_TAG")? {
            println!("info: looks like we are running on Travis");
            let slug = require_var("TRAVIS_REPO_SLUG")?;
            let commit_sha = require_var("TRAVIS_COMMIT")?;
            GitHubInformation {
                commit_sha,
                slug,
                tag,
                token,
            }
        } else if let Some(source_branch) = maybe_var("BUILD_SOURCEBRANCH")? {
            println!("info: looks like we are running on Azure Pipelines");

            let tag = source_branch.trim_start_matches("refs/tags/").to_owned();
            if tag == source_branch {
                return Err(format_err!(
                    "un-tag-like value for $BUILD_SOURCEBRANCH: {}",
                    source_branch
                ));
            }

            let slug = require_var("BUILD_REPOSITORY_NAME")?;
            let commit_sha = require_var("BUILD_SOURCEVERSION")?;
            GitHubInformation {
                commit_sha,
                slug,
                tag,
                token,
            }
        } else {
            return Err(format_err!(
                "could not determine build context from environment; set TRAVIS_{{COMMIT,TAG,REPO_SLUG}}"
            ));
        };

        println!(
            "info: uploading for {}:{} ({})",
            info.slug, info.tag, info.commit_sha
        );
        Ok(info)
    }

    fn make_blocking_client(&self) -> Result<reqwest::blocking::Client, Error> {
        use reqwest::header;
        let mut headers = header::HeaderMap::new();
        headers.insert(
            header::AUTHORIZATION,
            header::HeaderValue::from_str(&format!("token {}", self.token))?,
        );

        Ok(reqwest::blocking::Client::builder()
            .default_headers(headers)
            .build()?)
    }

    fn api_url(&self, rest: &str) -> String {
        format!("https://api.github.com/repos/{}/{}", self.slug, rest)
    }

    /// Get the upload URL for the release, possibly creating it. We can't
    /// mark the release as a draft, because then the API doesn't return any
    /// information for it.
    fn get_upload_url(&self, client: &mut reqwest::blocking::Client) -> Result<String, Error> {
        // Does the release already exist?

        let query_url = self.api_url(&format!("releases/tags/{}", self.tag));
        let resp = client.get(&query_url).send()?;
        if resp.status().is_success() {
            let mut parsed = json::parse(&resp.text()?)?;

            if let Some(s) = parsed["upload_url"].take_string() {
                // Return value includes template `{?name,label}` at the end.
                let v: Vec<&str> = s.split('{').collect();
                return Ok(v[0].into());
            }
        }

        // No. Looks like we have to create it. XXX: some hardcoded tag
        // handling.

        let release_name = if self.tag == "continuous" {
            "Continuous Deployment release".into()
        } else {
            format!("{} (not yet human-verified)", self.tag)
        };

        let release_description = if self.tag == "continuous" {
            format!("Continuous deployment of commit {}", self.commit_sha)
        } else {
            format!("Automatically generated for tag {}", self.tag)
        };

        let release_info = object! {
            "tag_name" => self.tag.clone(),
            "name" => release_name,
            "body" => release_description,
            "draft" => false,
            "prerelease" => true
        };

        let create_url = self.api_url("releases");
        let resp = client
            .post(&create_url)
            .body(json::stringify(release_info))
            .send()?;
        let status = resp.status();
        let mut parsed = json::parse(&resp.text()?)?;

        if status.is_success() {
            println!("info: created the release");
        } else {
            println!(
                "info: did not create release; assuming someone else did; {}",
                parsed
            );
            // XXXX resend initial request???
        }

        if let Some(s) = parsed["upload_url"].take_string() {
            let v: Vec<&str> = s.split('{').collect();
            return Ok(v[0].into());
        }

        Err(format_err!(
            "no upload_url item in GitHub API release creation response (handle failure case?)"
        ))
    }
}

#[derive(Debug, StructOpt)]
pub struct UploadGitHubReleaseArtifactOptions {
    #[structopt(
        long = "name",
        help = "The artifact name to use in the release (defaults to input file basename)"
    )]
    name: Option<String>,

    #[structopt(help = "The path to the file to upload")]
    path: PathBuf,
}

impl UploadGitHubReleaseArtifactOptions {
    fn cli(self) -> Result<(), Error> {
        use reqwest::header;

        let info = GitHubInformation::new()?;
        let mut client = info.make_blocking_client()?;

        // Make sure the file exists before we go creating the release!
        let file = File::open(&self.path)?;

        let name = match self.name {
            Some(n) => n,
            None => self
                .path
                .file_name()
                .ok_or_else(|| format_err!("input file has no name component??"))?
                .to_str()
                .ok_or_else(|| format_err!("input file cannot be stringified"))?
                .to_owned(),
        };

        let upload_url = info.get_upload_url(&mut client)?;
        println!("info: upload url = {}", upload_url);

        let url = reqwest::Url::parse_with_params(&upload_url, &[("name", &name)])?;
        let resp = client
            .post(url)
            .header(header::ACCEPT, "application/vnd.github.manifold-preview")
            .header(header::CONTENT_TYPE, "application/octet-stream")
            .body(file)
            .send()?;
        let status = resp.status();
        let mut parsed = json::parse(&resp.text()?)?;

        if !status.is_success() {
            println!("error: API response: {}", parsed);
            return Err(format_err!("creation of asset {} failed", name));
        }

        println!("info: success!");

        if let Some(s) = parsed["url"].take_string() {
            println!("info: asset url = {}", s);
        }

        Ok(())
    }
}

#[derive(Debug, StructOpt)]
#[structopt(name = "ttcitool", about = "Tectonic CI/CD helper tool.")]
pub enum CiToolCli {
    #[structopt(name = "upload-gh-artifact")]
    /// Upload a file as a GitHub release artifact.
    Upload(UploadGitHubReleaseArtifactOptions),
}

impl CiToolCli {
    fn cli(self) -> Result<(), Error> {
        match self {
            CiToolCli::Upload(opts) => opts.cli(),
        }
    }
}

fn main() -> Result<(), Error> {
    CiToolCli::from_args().cli()
}
