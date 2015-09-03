# GitDeployTimer

Derives commit to deployment times from a Git repo which is tagged appropriately - [sit|stg|prd]-[build number]

For example:

```
git tag -a sit-437 -m "SIT deploy complete" b9fad04cacd515ace5efff4641c6ba1eac0c294b
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'git_deploy_timer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install git_deploy_timer

## Usage

The main entry point is `GitDeployTimer.deploy_timings('[local or remote repo]')`.
 
## Example (slightly formatted for clarity)
 
```
$ ./bin/console
irb(main):002:0> GitDeployTimer.deploy_timings('~/Workspace/test-repo')
Cloning into '/var/folders/mm/ffn7bl9n0rg9th9vb0gyzxwh0000gp/T/d20150903-62757-1emd7zi'...
done.
=> [{"id"=>"ae95592d699181fa73af31aa40ab46267c5305c6", "commitTimestamp"=>Sat, 10 Apr 2010 12:05:00 +0100, "prdTimestamp"=>Wed, 02 Jun 2010 08:00:00 +0100, "sitTimestamp"=>Sat, 10 Apr 2010 12:30:00 +0100, "stgTimestamp"=>Wed, 14 Apr 2010 13:35:00 +0100, "commitToSitSecs"=>1500.0, "commitToSit"=>"25 minutes", "commitToStgSecs"=>351000.0, "commitToStg"=>"4 days, 1 hour, 30 minutes", "commitToPrdSecs"=>4564500.0, "commitToPrd"=>"1 month, 3 weeks, 1 day, 19 hours, 55 minutes"},
    {"id"=>"744a4292348a3cc1ff13efcdb3e4f6ed10c0a749", "commitTimestamp"=>Sat, 10 Apr 2010 12:00:00 +0100, "prdTimestamp"=>Wed, 02 Jun 2010 08:00:00 +0100, "sitTimestamp"=>Sat, 10 Apr 2010 12:30:00 +0100, "stgTimestamp"=>Wed, 14 Apr 2010 13:35:00 +0100, "commitToSitSecs"=>1800.0, "commitToSit"=>"30 minutes", "commitToStgSecs"=>351300.0, "commitToStg"=>"4 days, 1 hour, 35 minutes", "commitToPrdSecs"=>4564800.0, "commitToPrd"=>"1 month, 3 weeks, 1 day, 20 hours"},
    {"id"=>"b9fad04cacd515ace5efff4641c6ba1eac0c294b", "commitTimestamp"=>Sat, 10 Apr 2010 11:00:00 +0100, "prdTimestamp"=>Wed, 02 Jun 2010 08:00:00 +0100, "sitTimestamp"=>Sat, 10 Apr 2010 10:10:00 +0100, "stgTimestamp"=>Wed, 14 Apr 2010 13:35:00 +0100, "commitToSitSecs"=>3000.0, "commitToSit"=>"50 minutes", "commitToStgSecs"=>354900.0, "commitToStg"=>"4 days, 2 hours, 35 minutes", "commitToPrdSecs"=>4568400.0, "commitToPrd"=>"1 month, 3 weeks, 1 day, 21 hours"},
    {"id"=>"3bae97eded2635a4590804b0e5b6ce966206c4a8", "commitTimestamp"=>Sat, 10 Apr 2010 10:00:00 +0100, "prdTimestamp"=>Sat, 10 Apr 2010 10:20:00 +0100, "sitTimestamp"=>Sat, 10 Apr 2010 10:10:00 +0100, "stgTimestamp"=>Sat, 10 Apr 2010 10:15:00 +0100, "commitToSitSecs"=>600.0, "commitToSit"=>"10 minutes", "commitToStgSecs"=>900.0, "commitToStg"=>"15 minutes", "commitToPrdSecs"=>1200.0, "commitToPrd"=>"20 minutes"}]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).
