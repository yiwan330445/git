#!/bin/sh

test_description='Tests pack performance using bitmaps'
. ./perf-lib.sh

GIT_TEST_PASSING_SANITIZE_LEAK=0
export GIT_TEST_PASSING_SANITIZE_LEAK

test_perf_large_repo

test_expect_success 'create rev input' '
	cat >in-thin <<-EOF &&
	$(git rev-parse HEAD)
	^$(git rev-parse HEAD~1)
	EOF

	cat >in-big <<-EOF
	$(git rev-parse HEAD)
	^$(git rev-parse HEAD~1000)
	EOF
'

test_perf 'thin pack' '
	git pack-objects --thin --stdout --no-reuse-delta \
		--revs --sparse <in-thin >out
'

test_size 'thin pack size' '
	test_file_size out
'

test_perf 'thin pack with --path-walk' '
	git pack-objects --thin --stdout --no-reuse-delta \
		--revs --sparse --path-walk <in-thin >out
'

test_size 'thin pack size with --path-walk' '
	test_file_size out
'

test_perf 'big pack' '
	git pack-objects --stdout --no-reuse-delta --revs \
		--sparse <in-big >out
'

test_size 'big pack size' '
	test_file_size out
'

test_perf 'big pack with --path-walk' '
	git pack-objects --stdout --no-reuse-delta --revs \
		--sparse --path-walk <in-big >out
'

test_size 'big pack size with --path-walk' '
	test_file_size out
'

test_perf 'repack' '
	git repack -adf
'

test_size 'repack size' '
	pack=$(ls .git/objects/pack/pack-*.pack) &&
	test_file_size "$pack"
'

test_perf 'repack with --path-walk' '
	git repack -adf --path-walk
'

test_size 'repack size with --path-walk' '
	pack=$(ls .git/objects/pack/pack-*.pack) &&
	test_file_size "$pack"
'

test_done
