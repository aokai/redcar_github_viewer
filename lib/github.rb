module Redcar
  class Github
    def self.menus
      Menu::Builder.build do
        sub_menu "Project" do
          item "Project from Github", OpenGithubProjectCommand
        end
      end
    end


    def self.keymaps
      osx = Keymap.build('main', :osx) do
        link "Cmd+Shift+Alt+G", OpenGithubProjectCommand
      end

      linwin = Keymap.build('main', [:linux, :windows]) do
        link "Ctrl+Shift+Alt+G", OpenGithubProjectCommand
      end

      [linwin, osx]
    end

  end

  class OpenGithubProjectCommand < Command
    attr_accessor :rep_path, :user_name, :rep_name, :url

    def execute
      result = Application::Dialog.input(win,"Github Clone URL","Input the Clone URL")
      @url = result[:value]

      matched_result = @url.match("github.com\/(.*)\/(.*).git")
      unless matched_result == nil
        @user_name = matched_result[1]
        @rep_name = matched_result[2]
        @rep_path = "#{Redcar.user_dir}/github/clone/#{@user_name}/#{@rep_name}"

        Thread.new do
          system "git clone #{@url} #{@rep_path}"

          ApplicationSWT.sync_exec do
            new_window = Redcar.app.new_window
            tree = Tree.new(Project::DirMirror.new(@rep_path),Project::DirController.new)

            new_window.add_listener :closed do
              FileUtils.remove_entry_secure @rep_path if File.exists? @rep_path
            end

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
