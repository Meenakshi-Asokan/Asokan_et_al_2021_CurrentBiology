%%Here's some sample input
% data = cell(1,3);
% for i = 1:3
% data{i} = i*rand(1,i*10);
% end
% figure();
%%
function myfunc_boxplot(data)
%Function to create a boxplot with mean display as well
% - INPUT: data should be a cell array with each cell corresponding to the
% elements in one box, each cell could be of a diff size
% This function also adds the mean as a magenta circle
for i = 1:length(data)
    mean_data(i) = mean(data{i});
end
mat = [];
xaxiss = [];
for r_num = 1:3
    for i = 1:length(data{r_num})
        xaxiss{1,length(mat)+i} = (sprintf('%d',r_num));
    end
    mat = [mat data{r_num}];
end
boxplot(mat,xaxiss);
hold on
plot(mean_data,'om'); %Mean addition

end

