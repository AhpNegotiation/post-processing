function [negotiationChart, finalBids] = AIAA_RandomHeatmap(s, showchart)


% struct.bids: Nx2 array with player 1 & 2 bids
% struct.crits: Nx2 array with player 1 & 2 criterion ranking
% struct.wtn: Nx2 array with player 1 & 2 wtn
% struct.critNames: Nx1 cell array of criterion names (strings)

bidP1 = s.bids(:,1);
bidP2 = s.bids(:,2);
eigP1 = s.crits(:,1);
eigP2 = s.crits(:,2);
critNames = s.critNames;
wtn1 = s.wtn(:,1);
wtn2 = s.wtn(:,2);

% Bids: variable b7 is criteria only and wtn in col 1 and col 2____________
% let code calculate difference, store for ease of access
b4 = abs(bidP2-bidP1);
b3 = horzcat(bidP1,bidP2);
Bidsum = horzcat(bidP1,bidP2,b4);
index = size(bidP1,1);


% Normalize Criteria rank per plater
for n= 1:index
    c1(n) = eigP1(n)/(eigP1(n)+eigP2(n));
    c2(n) = eigP2(n)/(eigP1(n)+eigP2(n));
end

% Enter Will to Negotiate__________________________________________________


% Normalize Willingness to Negotiate Values
% Note that wps(i,2) uses wtn1 intentionally as high WTN lowers utility
% scaling factor
for i = 1:index
    wps(i,2) = wtn1(i)/(wtn1(i)+wtn2(i));
    wps(i,1) = wtn2(i)/(wtn1(i)+wtn2(i));
    i=i+1;
end
% _______________________________________________________________________ %

% Two player Bargain Linear Relation
for n = 1:index
    i=1;
    for x = 0:0.005:c1(n)
        m = -c2(n)/c1(n);
        y = m*x+c2(n);
        xy(i,1,n) = x; xy(i,2,n) = y;
        i=i+1;
    end
    % add x-intercept
    x = (0-c2(n))/m;
    xy(i,1,n) = x;
end

% With WTN
xyw = zeros(size(xy));
i=1;
for n = 1:index
    xyw(:,1,n) = xy(:,1,n).*wps(i,1); xyw(:,2,n) = xy(:,2,n).*wps(i,2);
    % Normalize
    xywn(:,1,n) = xyw(:,1,n)./(xyw(:,1,n)+xyw(:,2,n));
    xywn(:,2,n) = xyw(:,2,n)./(xyw(:,1,n)+xyw(:,2,n));
    % Set NaNs as zeros
    for i2 = 1:size(xywn,1)
        if isnan(xywn(i2,1,n))
            xywn(i2,1,n) = 0;
        end
        if isnan(xywn(i2,2,n))
            xywn(i2,2,n) =0;
        end
        i2=i2+1;
    end
    i=i+1;
end

% Locate Maximum Utility Point and save for later
utility = xy(:,1,:).*xy(:,2,:);
utilityw = xyw(:,1,:).*xyw(:,2,:);

for n = 1:index
    % Find maximum row for Crit only
    mx(n) = find(max(utility(:,1,n))==utility(:,1,n));
    point(n,:) = [xy(mx(n),1,n),xy(mx(n),2,n)];
    side(:,:,n) = vertcat([xy(mx(n),1,n),0],point(n,:));
    top(:,:,n) = vertcat([0,xy(mx(n),2,n)],point(n,:));
    
    % Find maximum row for With WTN
    mxw(n) = find(max(utilityw(:,1,n))==utilityw(:,1,n));
    pointw(n,:) = [xyw(mxw(n),1,n),xyw(mxw(n),2,n)]; % Inconsistency for plotting
    sidew(:,:,n) = vertcat([xyw(mxw(n),1,n),0],pointw(n,:));
    topw(:,:,n)  = vertcat([0,xyw(mxw(n),2,n)],pointw(n,:));
    pointw(n,:) = [xywn(mxw(n),1,n),xywn(mxw(n),2,n)]; % Correction for code later
end

%% 1D Plotting __________________________________________________________

% Find Maximum and Minimum bids for coding convenience
for n = 1:index
    bmint(n) = min(bidP1(n),bidP2(n));
    bmaxt(n) = max(bidP1(n),bidP2(n));
    bmin = bmint';
    bmax = bmaxt';
end
% Player 1's persepective - As taken from lines (roughly) 140-160
point1 = point(:,1)./( point(:,1)+ point(:,2));
pointw1 = pointw(:,1)./( pointw(:,1)+ pointw(:,2));

% Find Negotiation Point by player 1's perspective
for n = 1:index
    if bidP1(n)<bidP2(n)
        b5(n) = bmax(n) - b4(n).*point1(n)';  %Criteria only
        b6(n) = bmax(n) - b4(n).*pointw1(n)'; %Adjust by WTN
    else
        b5(n) = bmin(n) + b4(n).*point1(n)';  %Criteria only
        b6(n) = bmin(n) + b4(n).*pointw1(n)'; %Adjust by WTN
    end
end

b7 = [transpose(b5) transpose(b6)];

% Actual Plotting Code____________________________________________________
index2 = size(b3,2);
xaxis = zeros(index2,1);
negotiationChart = -1;
if(showchart)
    negotiationChart = figure();
    negotiationChart.Visible = 'off';
    for n = 1:index
        ax = subplot(2*index,1,2*n);
        plot(b3(n,:),xaxis,'linewidth',2,'color','k')
        
        text(b3(n,1),xaxis(1),['\uparrow ',num2str(b3(n,1))], ...
            'HorizontalAlignment','left','VerticalAlignment','top');
        text(b3(n,2),xaxis(1),[num2str(b3(n,2)),' \uparrow'], ...
            'HorizontalAlignment','right','VerticalAlignment','top');
        % text((b3(n,2)+b3(n,1))/2,xaxis(1),['\uparrow Equal Split'], ...
        text((b3(n,2)+b3(n,1))/2,xaxis(1),['\uparrow'], ...
            'HorizontalAlignment','left','VerticalAlignment','top','FontWeight','bold');
        if b3(n)<1
            xlower = sprintf(' Criteria = %0.2f ', b5(n));
            xupper = sprintf(' WTN = %0.2f ', b6(n));
        else
            xlower = sprintf(' Criteria = %0.0f ', b5(n));
            xupper = sprintf(' WTN = %0.0f ', b6(n));
        end
        
        text((b5(n)),xaxis(1),['\downarrow' xlower], ...
            'HorizontalAlignment','left','VerticalAlignment','bottom');
        % if (b6(n)-(b3(n,2)+b3(n,1))/2) > 0
        % text((b6(n)),xaxis(1),[xupper '\uparrow'], ...
        %    'HorizontalAlignment','right','VerticalAlignment','top');
        % else
        text((b6(n)),xaxis(1),['\uparrow' xupper], ...
            'HorizontalAlignment','left','VerticalAlignment','top');
        % end
        
        % Assign player 1 as left axis and player 2 as right axis
        if bidP1(n)>bidP2(n)
            view(180,0)
            xlim([bidP2(n) bidP1(n)])
        else
            xlim([bidP1(n) bidP2(n)])
        end
        % Clean the graphs, add the titles,
        % axis off
        ax.XTick = [];
        ax.YTick = [];
        ax.ZTick = [];
        
        if n == 1
            title('Player 1                                                                              Player 2');
        end
        ylabel(critNames(n));
        zlabel(critNames(n));
    end
end

finalBids = b7;

end
