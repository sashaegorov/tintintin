require 'uri'
require 'cgi'
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

# Usage example:
# I press localized "login.signin"[ within "form"]
When /^(?:|I )press localized "([^\"]*)"(?: within "([^\"]*)")?$/ do |button, selector|
  with_scope(selector) do
    click_button(eval "R18n.t.#{button}")
  end
end

# Usage example:
# I follow localized "login.signout"[ within "div"]
When /^(?:|I )follow localized "([^\"]*)"(?: within "([^\"]*)")?$/ do |link, selector|
  with_scope(selector) do
    click_link(eval "R18n.t.#{link}")
  end
end

# Usage example:
# I should see localized "title"[ within "h1"]
Then /^(?:|I )should see localized "([^\"]*)"(?: within "([^\"]*)")?$/ do |text, selector|
  with_scope(selector) do
    if page.respond_to? :should
      # TODO: Aviod ugly and slow `eval' if possible
      # Alchemist example
      # 3.hour.to.minutes.to_i > 3.hour.to.send(:minutes).send(:to_i)
      page.should have_content(eval "R18n.t.#{text}")
    else
      assert page.has_content?(eval "R18n.t.#{text}")
    end
  end
end

# Usage example:
# I should not see localized "error"[ within "h1"]
Then /^(?:|I )should not see localized "([^\"]*)"(?: within "([^\"]*)")?$/ do |text, selector|
  with_scope(selector) do
    if page.respond_to? :should
      page.should have_no_content(eval "R18n.t.#{text}")
    else
      assert page.has_no_content?(eval "R18n.t.#{text}")
    end
  end
end