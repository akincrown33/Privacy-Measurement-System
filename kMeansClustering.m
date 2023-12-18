function [clusters, clusterCenters] = kMeansClustering(dataSet,numClusters,numIterations)
    dataLength = size(dataSet,1);
    dataDim = size(dataSet,2);

    avgPoints = rand(numClusters,size(dataSet,2));
    for j = 1:dataDim
        avgPoints(:,j) = avgPoints(:,j)*(max(dataSet(:,j))-min(dataSet(:,j)))+min(dataSet(:,j));
    end
    
    for i = 1:numClusters
        j = ceil(rand*dataLength);
        while sum(ismember(avgPoints,dataSet(j,:),'rows')) ~= 0
            j = ceil(rand*dataLength);
        end
        avgPoints(i,:) = dataSet(j,:);
    end
    
    for iter = 1:numIterations
        dataSetAssignments = [dataSet ones(dataLength,1)];
        for i = 1:size(dataSetAssignments,1)
           minDist = norm(dataSetAssignments(i,1:dataDim).' - avgPoints(1,:).');
           minJ = 1;
           for j = 1:size(avgPoints,1)
               dist = norm(dataSetAssignments(i,1:dataDim).' - avgPoints(j,:).');
               if dist <= minDist
                   minJ = j;
                   minDist = dist;
               end
           end
           dataSetAssignments(i,dataDim+1) = minJ;
        end
        for i = 1:numClusters
            splitSet(:,:,i) = {dataSetAssignments(dataSetAssignments(:,dataDim+1)==i,1:dataDim)};
        end
        
        for i = 1:numClusters
            avg = mean(splitSet{i},1);
            avgPoints(i,:) = avg(1:dataDim);
        end
    end
    
    clusters = splitSet; clusterCenters = avgPoints;
end
