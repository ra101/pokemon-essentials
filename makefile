RUBY = wsl ruby
RPGXP = "C:\Program Files (x86)\Enterbrain\RPGXP\RPGXP.exe"
NOHUP = cmd /c start

drun: scripts_combine.rb scripts_extract.rb Game.exe
	$(RUBY) scripts_combine.rb --force && $(RUBY) scripts_extract.rb
	$(NOHUP) Game.exe debug

run: scripts_combine.rb Game.exe
	$(RUBY) scripts_combine.rb
	$(NOHUP) Game.exe

rpg: scripts_combine.rb Game.rxproj
	$(RUBY) scripts_combine.rb
	$(NOHUP) $(RPGXP) Game.rxproj

# dist: comming soon!
