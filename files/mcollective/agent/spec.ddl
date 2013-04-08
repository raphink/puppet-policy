metadata :name => "RSpec tests",
         :description => "RSpec tests",
         :author => "Raphaël Pinson",
         :license => "GPLv3",
         :version => "0.1",
         :url => "",
         :timeout => 60

action 'check', :description => "Run a check with the serverspec library" do
    display :always

    input :action,
          :prompt => "Action to check",
          :description => "",
          :type => :string,
          :validation => '^\S+$',
          :optional => false,
          :maxlength => 50

    input :values,
          :prompt => "Values to check",
          :description => "",
          :type => :string,
          :validation => '^\S+$',
          :optional => false,
          :maxlength => 100

    output :passed,
           :description => "Whether the checked passed",
           :display_as => "Passed"
end
