namespace :view_state do
  task :uuids => :environment do
    ViewState.all.each(&:save)
  end
end
