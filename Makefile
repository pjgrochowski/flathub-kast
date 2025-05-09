APPLICATION_ID := io.bitbucket.Kast
APPLICATION_MANIFEST := $(APPLICATION_ID).yml
APPLICATION_METAINFO := $(APPLICATION_ID).metainfo.xml

DIR_BUILD := builddir
DIR_REPO := repo

# That needs to run only once:
setup:
	flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo && \
	flatpak install -y flathub org.flatpak.Builder

clean:
	rm -rfv .flatpak-builder/ $(DIR_BUILD)/ $(DIR_REPO)/

uninstall:
	flatpak uninstall $(APPLICATION_ID)

build:
	flatpak run org.flatpak.Builder \
		--force-clean \
		--sandbox \
		--user \
		--install \
		--install-deps-from=flathub \
		--ccache \
		--mirror-screenshots-url=https://dl.flathub.org/media/ \
		--repo=$(DIR_REPO) \
		$(DIR_BUILD) \
		$(APPLICATION_MANIFEST)

validate: validate-manifest validate-repo validate-metainfo

validate-manifest:
	flatpak run --command=flatpak-builder-lint org.flatpak.Builder manifest $(APPLICATION_MANIFEST)

validate-repo:
	flatpak run --command=flatpak-builder-lint org.flatpak.Builder repo $(DIR_REPO)

validate-metainfo:
	flatpak run --command=flatpak-builder-lint org.flatpak.Builder appstream $(APPLICATION_METAINFO)

run:
	flatpak run $(APPLICATION_ID) -d
