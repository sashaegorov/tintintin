ignore %r{^.+.db$}
notification :terminal_notifier

# Watch all
guard :shell do
  watch(%r{^.+$}) { `git status --short` }
  watch(%r{^.+$}) { `git diff --stat` }
end

# Cucumber
guard :cucumber do
  watch(%r{^.+\.rb$}) { 'features' }
  watch(%r{views/.+\.(haml)$}) { 'features' }
  watch(%r{^features\/.+\.feature$}) { 'features' }
  watch(%r{^features\/support/.+$})  { 'features' }
  watch(%r{^features\/step_definitions/(.+)_steps\.rb$}) { |m| Dir[File.join("**/#{m[1]}.feature")][0] || 'features' }
end

# Livereload
guard :livereload, grace_period: 0.5 do
  watch(%r{views/.+\.(haml)$})
  watch(%r{public/.+\.(css|js|html)})
  watch(%r{i18n/.+\.(yml)})
end
