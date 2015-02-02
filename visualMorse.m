function visualMorse()
	% setting up the morse code hashmap
	keys={'12','2111','2121','211','1','1121','221','1111','11','1222','212','1211','22','21','222','1221','2212','121','111','2','112','1112','122','2112','2122','2211','22222','12222','11222','11122','11112','11111','21111','22111','22211','22221'};
	values={'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','0','1','2','3','4','5','6','7','8','9'};
	MorseMap = containers.Map(keys, values);

	% creating audion that sinalizes that 
	Fs = 1000; nSeconds=10; frequency = 400;
	y1 = 100*sin(linspace(0, nSeconds*frequency*2*pi, round(nSeconds*Fs)));
	morse_audio = audioplayer(y1, Fs);

	% setting up the camera object
	mywebcam =webcam;
	% wait a little while for the camera to be ready before acquiring the first image

    % elements to be updated
    el = {}
    % current sequence of clicks
    current = {-1};
    % time elapsed since begining of loop for each click
    time_el = {0}
    % current password generated
    current_pass = '';
    timestep = 1
	pause(2);

    tic;
	for idx = 1:50
		% acquire image from webcam
		rgbImage=snapshot(mywebcam);
		% resize for better performance
		rgbImage=imresize(rgbImage, [180 320]);
		% Convert to HSV color space
		hsv_img=rgb2hsv(rgbImage);

		if idx==1
			imshow(rgbImage);
			% capture coordinate of pixel in hand
			coords=ginput(1);
			% color of the pixel in the hsv color space
			hsv_color = impixel(hsv_img,coords(1),coords(2));
		end

		% compute largest blob, i.e a bw mask of the user's hand
		largest_blob = findLargestBlob( hsv_color, hsv_img );

	 	[num_fingers, final] = countFingers(largest_blob);

	    maskedBlue = largest_blob .* 255;
		maskedGreen = final .* 255;
		maskedRed = final .* 0;
	    % rgb image that shows hand blob and fingers at the same time
	    % for display porpuses only
		maskedRgbImage = cat(3, maskedRed, maskedGreen, maskedBlue);

		subplot(2,2,1),	imshow(rgbImage);
		subplot(2,2,2),	imshow(maskedRgbImage);
		subplot(2,2,[3,4]);

	    % If showing one finger, play tune
	    if num_fingers==1
	    	play(morse_audio);
	    else 
	    	stop(morse_audio);
	    end
		
		pause(0.1);
	end
	% disconnecting from camera
	clear('mywebcam');



end