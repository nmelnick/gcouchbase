#!/bin/sh

rm -rf valadoc
valadoc \
	-o valadoc \
	--basedir=.. \
	--package-name=couchbase \
	--package-version=0.1 \
	--deps \
	--vapidir=../vapi \
	--doclet=html \
	--driver=0.18.x \
	--pkg=glib-2.0 \
	--pkg=gmodule-2.0 \
	--pkg=libcouchbase \
	`find ../src -name \*.vala -print` \
	--force
