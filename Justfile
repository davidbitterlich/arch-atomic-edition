image_name := env("BUILD_IMAGE_NAME", "arch-atomic-edition")
image_tag := env("BUILD_IMAGE_TAG", "latest")
base_dir := env("BUILD_BASE_DIR", ".")
filesystem := env("BUILD_FILESYSTEM", "btrfs")
selinux := env("BUILD_SELINUX", "true")
default_desktop := env("DEFAULT_DESKTOP", "KDE")

options := if selinux == "true" { "-v /var/lib/containers:/var/lib/containers:Z -v /etc/containers:/etc/containers:Z -v /sys/fs/selinux:/sys/fs/selinux --security-opt label=type:unconfined_t" } else { "-v /var/lib/containers:/var/lib/containers -v /etc/containers:/etc/containers" }
container_runtime := env("CONTAINER_RUNTIME", `command -v podman >/dev/null 2>&1 && echo podman || echo docker`)
export CONTAINER_RUNTIME := container_runtime

# Helper function to get desktop-specific image name
_image_with_desktop desktop:
    @echo "{{image_name}}-$(echo {{desktop}} | tr '[:upper:]' '[:lower:]')"

build-containerfile $image_name=image_name $desktop=default_desktop:
    sudo {{container_runtime}} build -f Containerfile \
    --security-opt label=disable \
    --security-opt seccomp=unconfined \
    --build-arg DESKTOP="${desktop}" -t "${image_name}:latest" .

bootc $desktop=default_desktop *ARGS:
    #!/usr/bin/env bash
    DESKTOP_LOWER=$(echo "{{desktop}}" | tr '[:upper:]' '[:lower:]')
    IMAGE_WITH_DESKTOP="{{image_name}}-${DESKTOP_LOWER}"
    sudo {{container_runtime}} run \
        --rm --privileged --pid=host \
        -it \
        {{options}} \
        -v /dev:/dev \
        -e RUST_LOG=debug \
        -v "{{base_dir}}:/data" \
        "${IMAGE_WITH_DESKTOP}:{{image_tag}}" bootc {{ARGS}}

generate-bootable-image $base_dir=base_dir $desktop=default_desktop $filesystem=filesystem:
    #!/usr/bin/env bash
    if [ ! -e "${base_dir}/bootable.img" ] ; then
        fallocate -l 64G "${base_dir}/bootable.img"
    fi
    just bootc desktop=$DESKTOP install to-disk --composefs-backend --via-loopback /data/bootable.img --filesystem "${filesystem}" --wipe --bootloader systemd


build-iso:
    #!/usr/bin/env bash
    set -xeuo pipefail
    sudo $CONTAINER_RUNTIME run \
        --rm --privileged --pid=host \
        -v "{{base_dir}}:/data" \
        ghcr.io/davidbitterlich/arch-bootc:latest \
        sh -euxo pipefail -c '
            pacman -Sy --noconfirm archiso

            curl -s https://api.github.com/repos/frostyard/nbc/releases/latest \
            | jq -r ".assets[] | select(.name | test(\"linux_amd64.tar.gz\")) | .browser_download_url" \
            | xargs curl -L -O

            mkarchiso -v -w /tmp/work -o /data/out /data/build_files/archlive
        '