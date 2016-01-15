% Source by CAD
% http://www.cad.zju.edu.cn/home/dengcai/Data/MNIST/images.html
% Updated 12/13/15 by kotulc

function displayMNISTSample(images, labels, idx=0, sampleN=0)
	
	if(idx==0)
		% Randomize the example set
		n = rand(size(images,1),1);
		[g idx] = sort(n);
		images = images(idx,:);
		labels = labels(idx,:);
	end
	if (sampleN == 0)
		sampleN = numel(idx);
	end
	images = images(1:100,:);

	faceW = 28; 
	faceH = 28; 
	numPerLine = 20; 
	ShowLine = 5; 

	disp("\nImage labels:");
	Y = zeros(faceH*ShowLine,faceW*numPerLine); 
	for i=0:ShowLine-1 
		for j=0:numPerLine-1 
			Y(i*faceH+1:(i+1)*faceH,j*faceW+1:(j+1)*faceW) = reshape(images(i*numPerLine+j+1,:),[faceH,faceW]); 
		end 
	end 

	for i=0:ShowLine-1
		for j=1:numPerLine
			printf("%d  ",labels((i*numPerLine + j)));
		end
		disp("");
	end
	
	imagesc(Y);colormap(gray);
		
end

