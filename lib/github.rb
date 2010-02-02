module Redcar
	class Github
		def self.menus
			Menu::Builder.build do
				sub_menu "Project" do
					item "Project from Github", OpenGithubProjectCommand
				end
			end
		end
		
		def self.loaded
			# This should happen when Redcar is closed
			FileUtils.remove_entry_secure "#{Redcar.user_dir}/github/clone"
		end
	end
	
	class OpenGithubProjectCommand < Command
		key :osx 	 => "Cmd+Shift+G",
			:linux	 => "Ctrl+Shift+G",
			:windows => "Ctrl+Shift+G"
			
		attr_accessor :rep_path, :user_name, :rep_name, :url
			
		def execute
			result = Application::Dialog.input(win,"Github Clone URL","Input the Clone URL")			
			@url = result[:value]
			
			matched_result = @url.match("github.com\/(.*)\/(.*).git")
			unless matched_result == nil
				@user_name = matched_result[1]
				@rep_name = matched_result[2]
				@rep_path = "#{Redcar.user_dir}/github/clone/#{@user_name}/#{@rep_name}"
				
				Thread.new(self, window) do |command, window|
					system "git clone #{@url} #{@rep_path}" 
					
					ApplicationSWT.sync_exec do
						new_window = Redcar.app.new_window
        				tree = Tree.new(Project::DirMirror.new(@rep_path),Project::DirController.new)
                        
        				Project.open_tree(new_window, tree)
					end
				end
			else
				Application::Dialog.message_box(
					win,
					"Wrong format for the url: #{@url} . Use the clone url from github.", 
					:type => :error )
			end
		end
	end
end