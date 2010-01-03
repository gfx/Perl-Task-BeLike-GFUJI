use inc::Module::Install;
name 'Task-BeLike-GFUJI';
all_from 'lib/Task/BeLike/GFUJI.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
