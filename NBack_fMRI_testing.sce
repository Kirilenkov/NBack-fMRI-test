# -----------------headers----------------- #
no_logfile = true;
active_buttons = 2;
write_codes = false;
response_port_output = false;
default_background_color = 0, 0, 0;
default_text_color = EXPARAM("Default stim color");

# ----------------- SDL ------------------- #
begin;

$col = EXPARAM("Default stim color");
$cross_size = EXPARAM("Cross size");

line_graphic {
	coordinates = 0, $cross_size, 0, '0 - $cross_size';
	coordinates = $cross_size, 0, '0 - $cross_size', 0;
	line_width = 4;
	line_color = $col;
	display_index = 2;
} cross;

text {
	caption = "";
	preload=false;
	display_index = 2;
}letter;

text {
	caption = "";
	preload=false;
	display_index = 1;
}oper_text;

trial {
	trial_type = fixed;
	stimulus_event {
		picture {
			display_index = 2;
		} main_pic;
	}main_event;
}main_trial;

trial {
	trial_type = fixed;
	picture {
		display_index = 1;
		text oper_text;
		x = 0;
		y = 0;
	}oper_pic;
}operator_trial;

# ----------------- PCL ------------------- #
begin_pcl;

array <string> letters[0];
parameter_manager.get_strings("Letters", letters);
int oper_text_size = parameter_manager.get_int("Operator text size");
int partic_text_size = parameter_manager.get_int("Participant text size");
int cue_dur = parameter_manager.get_int("Cue duration");
int lett_dur = parameter_manager.get_int("Letter duration");
bool perf_cue = parameter_manager.get_bool("Enable cue");

oper_text.set_caption(parameter_manager.get_string("Performing instructions"));
oper_text.ALIGN_CENTER;
oper_text.set_font_size(oper_text_size);
oper_text.redraw();
operator_trial.present();

sub string set_letter_val(string temp_val, array<string, 1> letter_arr)
	# to disable double repetition
	begin
		string result;
		string val = letter_arr[random(1, letters.count())];
		if (val == temp_val) then
			result = set_letter_val(temp_val,letter_arr)
		else
			result = val;
		end;
		return result;
	end;

sub main
	begin
	letter.set_font_size(parameter_manager.get_int("Participant text size"));
	main_pic.add_part(cross, 0, 0);
	string previous_letter = "";
	string letter_val;
	bool stop_trigger = false;
	loop until stop_trigger
		begin
			if perf_cue then
				main_trial.set_duration(cue_dur);
				main_trial.present();
			end;
			letter_val = set_letter_val(previous_letter, letters);
			letter.set_caption(letter_val);
			previous_letter = letter_val;
			letter.redraw();
			main_pic.set_part(1, letter);
			main_trial.set_duration(lett_dur);
			main_trial.present();
			if perf_cue then
				main_pic.set_part(1, cross);
			end;
		end;
	end;
	
main();