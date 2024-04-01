# onshape-std-library-importer

This is the thing that keeps [onshape-std-library-mirror](https://github.com/javawizard/onshape-std-library-importer) up to date. See that repo's [README](https://github.com/javawizard/onshape-std-library-mirror/blob/main/README.md) for more info on what this is.

## Local development

(Right now the script is hardcoded to push and pull from [javawizard/onshape-std-library-mirror](https://github.com/javawizard/onshape-std-library-mirror), so only I can run it at the moment. PRs gladly accepted to make the remote configurable.)

To run the importer locally, you'll first need an Onshape account. You can sign up for one for free [here](https://www.onshape.com/en/sign-up-form) as long as you're fine with all of your documents being public.

Then you'll need to set up an Onshape API key. Head over to the Onshape [developer portal](https://dev-portal.onshape.com/keys), click the "Create new API key button", check "Application can read your documents", then click "Create API key". Then turn the key into an HTTP basic authentication header by running the following:

```
echo -n 'Basic ' && (echo -n '<access key>:<secret key>' | base64)
```

where `<access key>` and `<secret key>` are the keys shown in the Onshape developer portal after you clicked the "Create API key" button.

That'll spit out the `Authorization:` header value the script will use to authenticate to Onshape's API.

Then clone this repo and create a directory inside it called `local` and add a script called `read-auth-header` that prints out the above header value you just generated. Everything inside `local` is `.gitignore`'d, so you can save the token directly to the file:

```
#!/bin/bash

echo 'Basic <bunch of base64-encoded stuff>'
```

Or you can get fancy and store it in a 1Password vault like I do and pull it out using 1Password's [excellent CLI](https://developer.1password.com/docs/cli/):

```
#!/bin/bash

op read "op://Personal/<item id>"
```

Either way, you'll want to `chmod +x local/read-auth-header` once you're done.

Then run `./onshape-download-std-library` from the root of the repository and you're off to the races!

## Deployment

`onshape-std-library-importer` runs out of the box on [Dokku](https://dokku.com/). It'll also run on any host with Docker installed, but you'll need to take care of kicking off the script on a schedule if you're not using Dokku.

Set up Dokku as you usually would, then create an app called `onshape-std-library-importer`. Set the following environment variables using `dokku config:set onshape-std-library-importer`:

- `AUTH_HEADER`: set this to the auth header your `local/read-auth-header` script is set up to output above
- `GITHUB_SSH_KEY`: set to the full RSA private key of a newly-generated SSH keypair, then add the corresponding public key as a [deploy key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/managing-deploy-keys) on the repo you want the script to push to (hardcoded to `javawizard/onshape-std-library-importer` right now, as noted above; PRs gladly accepted to make this configurable). Make sure the deploy key has permission to write to the repo.

Then add `dokku@<your-dokku-host>:onshape-std-library-importer` as a remote to your local git clone and push the `main` branch to that remote. It'll build the docker image, set up the cron job, and then return.

At this point the script will automatically run every hour. If you want to run it manually, either to fetch updates ahead of schedule or to see the log output to ensure it's working, run this:

```
ssh dokku@<your-dokku-host> cron:list onshape-std-library-importer
```

Copy the ID it prints out, then run:

```
ssh dokku@<your-dokku-host> cron:run <id>
```

where `<id>` is the ID you copied. It'll run the script and live stream its output. Check to make sure everything's working and you're done!

## Feedback

Feel free to open an issue if there's something you'd like to see changed, or feel free to submit a PR.
