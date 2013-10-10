notification :terminal_notifier

# Livereload
guard 'livereload', grace_period: 0.5 do
  watch(%r{(actions|common|helpers)/.+\.(rb)$})
  watch(%r{views/.+\.(haml)$})
  watch(%r{public/.+\.(css|js|html)})
  watch(%r{i18n/.+\.(yml)})
end

# Cucumber
guard 'cucumber' do
  watch(%r{(actions|common|helpers)/.+\.(rb)$})
  watch(%r{^features/.+\.feature$})
  watch(%r{^features/support/.+$})          { 'features' }
  watch(%r{^features/step_definitions/(.+)_steps\.rb$}) { |m| Dir[File.join("**/#{m[1]}.feature")][0] || 'features' }
end