Before do
  step %(I run `mamp stop mysql`)
end

Given(/^that MySQL did not already start$/) do
  `ps a | grep mysql | grep -v 'grep mysql'`.should == ''
end

Then(/^MySQL should be running$/) do
  `ps a | grep mysql | grep -v 'grep mysql'`.should_not == ''
end

After do
  step %(I successfully run `mamp stop mysql`)
end
