#!/bin/bash
# Script to update apt repository metadata

REPO_DIR="$HOME/0hex01-apt-repo-unstable"
DIST="unstable"
COMPONENT="main"
ARCH="amd64"
KEY_ID="F68F020A817D6F1F4A1D1EF2619B08066E472D19"

cd "$REPO_DIR" || exit 1

# Generate Packages file
dpkg-scanpackages --multiversion dists/$DIST/$COMPONENT/binary-$ARCH /dev/null > dists/$DIST/$COMPONENT/binary-$ARCH/Packages 2>/dev/null || true
gzip -9c dists/$DIST/$COMPONENT/binary-$ARCH/Packages > dists/$DIST/$COMPONENT/binary-$ARCH/Packages.gz

# Generate Release file
cat > dists/$DIST/Release <<REOF
Origin: Personal Repository
Label: Personal Packages
Suite: unstable
Codename: unstable
Architectures: amd64
Components: main
Description: Personal apt repository
Date: $(date -R -u)
REOF

# Append checksums
cd dists/$DIST
for file in $(find . -type f -name "Packages*"); do
    size=$(stat -c%s "$file")
    md5=$(md5sum "$file" | cut -d' ' -f1)
    sha256=$(sha256sum "$file" | cut -d' ' -f1)
    echo "MD5Sum:" >> Release
    echo " $md5 $size ${file#./}" >> Release
    echo "SHA256:" >> Release
    echo " $sha256 $size ${file#./}" >> Release
done

# Sign Release file (--yes: overwrite sigs without prompting)
gpg --yes --default-key "$KEY_ID" --armor --detach-sign --output Release.gpg Release
gpg --yes --default-key "$KEY_ID" --clearsign --output InRelease Release

echo "Unstable repository metadata updated successfully!"
