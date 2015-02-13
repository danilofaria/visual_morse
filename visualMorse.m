function visualMorse()
	% setting up the morse code hashmap
	keys={'12','2111','2121','211','1','1121','221','1111','11','1222','212','1211','22','21','222','1221','2212','121','111','2','112','1112','122','2112','2122','2211','22222','12222','11222','11122','11112','11111','21111','22111','22211','22221'};
	values={'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','0','1','2','3','4','5','6','7','8','9'};
	MorseMap = containers.Map(keys, values);

	% creating audion that sinalizes that 
	Fs = 1000; nSeconds=10; frequency = 400;
	y1 = 100*sin(linspace(0, nSeconds*frequency*2*pi, round(nSeconds*Fs)));
	morse_audio = audioplayer(y1, Fs);

	clear('mywebcam');

	% setting up the camera object
	mywebcam =webcam;
	% wait a little while for the camera to be ready before acquiring the first image

    % elements to be ploted for information
    % array is kept in order for them to be deleted and updated
    plot_els = {}
    % current sequence of clicks
    current = {-1};
    % time elapsed since begining of loop for each click
    time_el = {0}
    % current password generated
    current_pass = '';
    PASSWORD = 'NEWYORK';
    timestep = 1
	pause(1);
	time_passed = 0.0;
	tic;
    figure();
	    
    first_iteration = true;

	while true 
		time_passed = time_passed + toc;
		% acquire image from webcam
		rgbImage=snapshot(mywebcam);
		% I found out that when calling this function
		%, toc resets to 0.0 (probably a bug)
		tic;

		% resize for better performance
		rgbImage=imresize(rgbImage, [180 320]);
		% Convert to HSV color space
		hsv_img=rgb2hsv(rgbImage);

		if first_iteration
			imshow(rgbImage);
			% capture coordinate of pixel in hand
			coords=ginput(1);
			% color of the pixel in the hsv color space
			hsv_color = impixel(hsv_img,coords(1),coords(2));
			first_iteration = false;
		end

		% compute largest blob, i.e a bw mask of the user's hand
		largest_blob = findLargestBlob( hsv_color, hsv_img );

	 	[num_fingers, final, cx, cy] = countFingers(largest_blob);

	    maskedBlue = largest_blob .* 255;
		maskedGreen = final .* 255;
		maskedRed = final .* 0;
	    % rgb image that shows hand blob and fingers at the same time
	    % for display porpuses only
		maskedRgbImage = cat(3, maskedRed, maskedGreen, maskedBlue);

		subplot(2,2,1),	imshow(rgbImage);
		subplot(2,2,2),	imshow(maskedRgbImage);
		line(cx, cy, 'Marker', '*', 'MarkerEdgeColor', 'r');
		subplot(2,2,[3,4]);
	    % If showing one finger
		if num_fingers==1
			% play tune
	    	play(morse_audio);
			% if previous click was off, add on click
			if (current{end}==0)
				current=[current,1];
				time_el=[time_el,time_passed];
			% if previous click was a while ago (one timestep)
			elseif timestep <= (time_passed-time_el{end})
				% if previous click was one, make it double on
				if current{end}==1
					current{end}=2;
					time_el{end}=time_passed;
				% otherwise, add on click
				elseif current{end}~=2
					current=[current,1];
					time_el=[time_el,time_passed];
				end
			end
		% If showing no fingers
		elseif num_fingers==0
			% if previous click was not off, add off click
			if (current{end}~=0)
				current=[current,0];
				time_el=[time_el,time_passed];
			% otherwise, if previous click was two timesteps before
			% consider it end of character transmission
			elseif 2*timestep <= (time_passed-time_el{end})
				% compute key for consulting hash map 
				str = '';
				for w=1:length(current)
					cod = current{w};
					if cod == 1 || cod == 2 
						str = strcat(str,int2str(cod));
					end				
				end
				% Check if key is in hash map and add it to current password if so
				if MorseMap.isKey(str)
					current_pass = strcat(current_pass, MorseMap(str))
				end
				% reset current character
			    current = {-1};	
			end
			stop(morse_audio);
		elseif num_fingers==5
			current={-1}
			stop(morse_audio);
			if strcmp(current_pass, PASSWORD)
				h = msgbox('Password correct!', 'Welcome')
				break;
			end
		else 
			stop(morse_audio);
		end

		for i=1:10
			plot_els =[plot_els ,rectangle('Position',[5+i*10, 7, 10, 10])];
		end

		sq_i = 10;
		cod_i = length(current);
		while(sq_i > 0 && cod_i > 0)
			cod=current{cod_i};
			cod_i = cod_i-1;
			if(cod==0)
			    sq_i = sq_i -1;
			elseif(cod==1)
			    plot_els =[plot_els ,line(10+sq_i*10, 12, 'Marker', 'O', 'MarkerFaceColor', 'b', 'LineWidth', 10)];
			    sq_i = sq_i -1;
			elseif(cod==2)
			    plot_els =[plot_els ,line([10+sq_i*10 10+(sq_i-1)*10], [12 12], 'LineWidth', 10)];
			    sq_i = sq_i -2;
			end
		end

	    plot_els =[plot_els ,text(5, 0, strcat('Number of fingers: ',int2str(num_fingers)),'FontSize',15)];
	    plot_els =[plot_els ,text(5, 4, strcat('Current Password: ',current_pass),'FontSize',15)];
		axis equal;
		axis off;
		
		pause(0.1);
		% erase elements plotted for information 
		delete(plot_els);
	end
	% disconnecting from camera
	clear('mywebcam');
end