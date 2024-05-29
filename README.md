# GitHub Action: Deploy with SSH

This GitHub workflow action tars and gzips the content of local `files` directory and gives the file a unique name containing an ISO second timestamp (ex: files-20240528163059.tar.gz). The compressed file is then securely copied to the hard-coded target host with `scp` as a hard-coded user using the passed `SSHKEY` (which should be passed from `{{ secrets.SSHKEY }}`) as the identity private key. After the file is copied a hard-coded remote command is called via `ssh` to trigger remaining tasks needed for remote deployment. The remote deployment executable must be highly restricted and/or governed by inclusion in the `sudoers` file. (See the beginning of the [entrypoint](entrypoint) script for hard-coded values.)

## Example usage

```yaml
    runs-on: ubuntu-latest
    name: Build and deploy to ssh target
    steps:

      - name: Build it
        run: |
          echo "#!/bin/sh" >> hello
          echo "echo hello world" >> hello
          chmod +x hello

      - name: Collect artifacts
        run: |
          mkdir ./files
          cp hello ./files
          find .

      - name: Deploy with ssh/scp
        uses: rwxrob-ghtest1/deploy-with-ssh@v1
        env:
          SSHKEY: ${{ secrets.SSHKEY }}

```

## Testing

The [`entrypoint`](entrypoint) script is designed to be tested by simply running it on the same computer without the need to call it from a GitHub action.

First symlink the [`apply-tar`](apply-tar) script to simulate its pre-installation on the target host.

```sh
mkdir -p ~/.local/bin
ln -s $PWD/apply-tar ~/.local/bin/apply-tar
```

Create an ssh key (if not already available).

```sh
ssh-keygen -t ed25519
```

Make sure to add the same key to the `authorized_keys` file (for simulating remote access).

```sh
cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
```

Add one or more files to the local files directory (already in [`.gitignore`](.gitignore)).

```sh
mkdir files
touch files/{foo,bar}
```

Then simply run the `entrypoint` script like any other making sure to give it the same identity key that has been added to `authorized_keys` above. Be sure to use the private SSH key file and not the public key.

```
SSHKEY="$(cat ~/.ssh/id_ed25519)" ./entrypoint
```
