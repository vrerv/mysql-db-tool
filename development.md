
If you use bundler >= 2.x, you can use Gemlock.file.
to create symlink for bundler 2.x use following command to create symlink for Gemfile.lock

```shell
rake bundler:symlink_lockfile
```

run without install

```shell
ruby -Ilib bin/mysql_backup local 0 false false
```

test

```shell
bundle exec rspec
```

push

```shell
gem build mysql_db_tool.gemspec
gem push mysql_db_tool-0.1.0.gem
```
