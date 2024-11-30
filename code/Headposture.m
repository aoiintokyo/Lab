%最初にクリアする
clc
clear
close all

%保存先のエクセル
excel_name ='/Users/kajitsukasousei/Personal/Lab/HeadPosture/data/excel/tmp.xlsx';


%取ったデータの数だけ回す
for data_num = 0:55
    disp(data_num)
    try
        %1回目のみ先頭に特徴量の名前を書く
        if data_num == 0
            D = ["BPM_c" "PG_c" "NG_c" "SG_c" "PPG_c" "PNG_c" "MA_c" "TR-c"  "RR" "RD" "SBP" "DBP" "EP"];
            writematrix(D,excel_name,'Range','A1');
        end

        %読み込むファイル名を取得し、格納
        num = num2str(data_num); %文字列に変換
        % 現在のスクリプトのディレクトリを取得
        currentDir = fileparts(mfilename('fullpath'));
        % data/csv ディレクトリへのパスを作成
        csvDir = fullfile(currentDir,'..','data', 'csv','20241116');
        data_name_chest = fullfile(csvDir, append('Z_', num, '.csv'));
        disp(data_name_chest);

    
        %データの読み込み開始
        allChestdatafile = readmatrix(data_name_chest);
        row_Chest = allChestdatafile(23:10023,2); %23から10001までのデータを入れる。chest変数の2列目の値 
        
        
        %graph 時間軸、データ収集にかかった時間を100000で割って時間軸を格納している、
        sweep_time_Chest = 9.37; %network analyzerの値
        for i=0:10000
            pre_x = (sweep_time_Chest/10000) * i;
            X_Chest(i+1,1) = pre_x;%row chest data, xlabel, time
        end
        
        
        N = 8192; %データ数
        fs_Chest = 10000/sweep_time_Chest;%サンプリング周波数:データのサンプリングレート（1秒辺りのサンプル数）単位Hz
        [filter_Chest, e] = bandpass(row_Chest,[0.9 5],fs_Chest,'ImpulseResponse','iir');%バンドパス 通過帯域周波数範囲；0.9~5Hz
        
        
        
        
        %2番目:検出された呼吸の極大値・極小値検出と座標の保存
        [filter_Res_Chest, e] = lowpass(row_Chest,0.9,fs_Chest,'ImpulseResponse','iir');%バンドパス0~0.9Hz
        filter_Res_Chest_inverted = -filter_Res_Chest; %極小値をpeak値で測定するためにグラフを反転させる
        [pks_Res_lower, locs_Res_lower] = findpeaks(filter_Res_Chest_inverted,X_Chest,"MinPeakDistance",2.0);%下のピーク検出
        pks_Res_lower = -pks_Res_lower; %元に戻す
        [pks_Res_upper, locs_Res_upper] = findpeaks(filter_Res_Chest,X_Chest);%上のピーク検出　ここはMinPeakDistance必要ないの？
        


        while locs_Res_upper(1) < locs_Res_lower(1) %locs_Res_upper(1) peak値一番最初のx座標位置
            locs_Res_upper(1) = [];
            pks_Res_upper(1) = [];
        end



        %極大値・極小値以外の値（極値）を削除する
        if ~(length(locs_Res_upper)==1 || length(locs_Res_lower)==1)
            while locs_Res_upper(2) < locs_Res_lower(2)
                if pks_Res_upper(1) > pks_Res_upper(2)
                    locs_Res_upper(2) = [];
                    pks_Res_upper(2) = [];
    
                    if length(locs_Res_upper)==1
                        flag=1;
                        break
                    end
                    if length(locs_Res_lower)==1
                        flag=1;
                        break
                    end
                else
                    locs_Res_upper(1) = [];
                    pks_Res_upper(1) = [];
                    
                    if length(locs_Res_upper)==1
                        flag=1;
                        break
                    end
                    if length(locs_Res_lower)==1
                        flag=1;
                        break
                    end
                 end
            end
        else
            flag=1;
        end
% 波形とピークをプロット
figure;
plot(X_Chest, filter_Res_Chest);
hold on;

% 下側ピークを赤い逆三角形でプロット
plot(locs_Res_lower, pks_Res_lower, 'r^', 'MarkerFaceColor', 'r');
plot(locs_Res_upper, pks_Res_upper, 'rv', 'MarkerFaceColor', 'b');

hold off;
xlabel('Time [s]');
ylabel('Amplitude');
title(['データ番号 ', num, ' のフィルタリングされた波形と下側ピーク']);
grid on;
legend('Filtered Signal', 'Lower Peaks');
           
   

        %1呼吸波形分取り出し
        limit_start = find(X_Chest==locs_Res_lower(1));
        limit_end = find(X_Chest==locs_Res_lower(2));
        limit_row_Chest = row_Chest(limit_start-1:limit_end+1);
        for i=1:limit_end-limit_start+3
            limit_X_Chest(i) = X_Chest(i);
        end
        
        

        %脈波検出バンドパスフィルタ
  
       [filter_limit_Chest, e] = bandpass(limit_row_Chest,[0.9 5],fs_Chest,'ImpulseResponse','iir');%バンドパス0.9~5Hz
   
        %ピーク検出
        filter_limit_Chest_inverted = -filter_limit_Chest;
        [pks_Pulse_lower_Chest, locs_Pulse_lower_Chest] = findpeaks(filter_limit_Chest_inverted,limit_X_Chest,"MinPeakHeight",0.02);%下のピーク検出
        pks_Pulse_lower_Chest = -pks_Pulse_lower_Chest;
        [pks_Pulse_upper_Chest, locs_Pulse_upper_Chest] = findpeaks(filter_limit_Chest,limit_X_Chest);%上のピーク検出
       






        %＊上のfor文を書き直し：locs_Pulse_lower_Chestの要素数に合わせてfor文の範囲設定
        for pc = 1:numel(locs_Pulse_lower_Chest)-1
            while locs_Pulse_upper_Chest(pc) < locs_Pulse_lower_Chest(pc)
                locs_Pulse_upper_Chest(pc) = [];
                pks_Pulse_upper_Chest(pc) = [];
            end
        end
        
        
        %計算 1脈波波形分　論文５　機械学習のための特徴量の導入
        for i = 1:length(locs_Pulse_lower_Chest)-1
      
            P_time_lower_Chest(i) = locs_Pulse_lower_Chest(i+1) - locs_Pulse_lower_Chest(i);
            Amp_Chest(i) = (pks_Pulse_upper_Chest(i) - pks_Pulse_lower_Chest(i) - pks_Pulse_lower_Chest(i+1) + pks_Pulse_upper_Chest(i)) / 2;
            PGT_Chest(i) = locs_Pulse_upper_Chest(i) - locs_Pulse_lower_Chest(i);%立ち上がり時間
            PGA_Chest(i) = pks_Pulse_upper_Chest(i) - pks_Pulse_lower_Chest(i);%立ち上がり振幅
            NGT_Chest(i) = locs_Pulse_lower_Chest(i+1) - locs_Pulse_upper_Chest(i);%立ち下がり時間
            NGA_Chest(i) = pks_Pulse_upper_Chest(i) - pks_Pulse_lower_Chest(i+1);%立ち下がり振幅
            PG_Chest(i) = PGA_Chest(i)/PGT_Chest(i);%立ち上がり勾配
            NG_Chest(i) = NGA_Chest(i)/NGT_Chest(i);%立ち下がり勾配
            N_PG_Chest(i) = PG_Chest(i)/P_time_lower_Chest(i)/Amp_Chest(i);%正規化立ち上がり
            N_NG_Chest(i) = NG_Chest(i)/P_time_lower_Chest(i)/Amp_Chest(i);%正規化立ち下がり
        end
        if i>2
            for j = 1:i-1
                Ptime_change_Chest(j) = abs(P_time_lower_Chest(j+1) - P_time_lower_Chest(j));
            end
            ave_P_time_Chest = mean(P_time_lower_Chest);
            P_rate_Chest = 60 / ave_P_time_Chest;
            ave_N_PG_Chest = mean(N_PG_Chest);
            ave_N_NG_Chest = mean(N_NG_Chest);
            N_SG_Chest = ave_N_PG_Chest + ave_N_NG_Chest;
            ave_PGT_Chest = mean(PGT_Chest);
            ave_NGT_Chest = mean(NGT_Chest);
            ave_A_Chest = mean(Amp_Chest);
            ave_Ptime_change_Chest = mean(Ptime_change_Chest);
            R_time = locs_Res_lower(2) - locs_Res_lower(1);
            R_rate = 60 /  R_time;
            R_depth = (pks_Res_upper(1) - pks_Res_lower(1) + pks_Res_upper(1) - pks_Res_lower(2)) / 2;
            sprintf('脈拍数：%f[bpm]\n正規化立ち上がり：%f[/s]\n正規化立ち下がり：%f[/s]\n正規化傾き合計：%f[/s]\n立ち上がり時間：%f[s]\n立ち下がり時間：%f[s]\n平均振幅：%f\n脈波周期揺らぎ：%f[s]\n呼吸数：%f[bpm]\n呼吸の深さ：%f',P_rate_Chest, ave_N_PG_Chest, ave_N_NG_Chest, N_SG_Chest, ave_PGT_Chest, ave_NGT_Chest, ave_A_Chest, ave_Ptime_change_Chest, R_rate, R_depth)
        else 
            flag=1;
            ave_Ptime_change_Chest = NaN;
            ave_P_time_Chest = mean(P_time_lower_Chest);
            P_rate_Chest = 60 / ave_P_time_Chest;
            ave_N_PG_Chest = mean(N_PG_Chest);
            ave_N_NG_Chest = mean(N_NG_Chest);
            N_SG_Chest = ave_N_PG_Chest + ave_N_NG_Chest;
            ave_PGT_Chest = mean(PGT_Chest);
            ave_NGT_Chest = mean(NGT_Chest);
            ave_A_Chest = mean(Amp_Chest);
            R_time = locs_Res_lower(2) - locs_Res_lower(1);
            R_rate = 60 /  R_time;
            R_depth = (pks_Res_upper(1) - pks_Res_lower(1) + pks_Res_upper(1) - pks_Res_lower(2)) / 2;
            sprintf('脈拍数：%f[bpm]\n正規化立ち上がり：%f[/s]\n正規化立ち下がり：%f[/s]\n正規化傾き合計：%f[/s]\n立ち上がり時間：%f[s]\n立ち下がり時間：%f[s]\n平均振幅：%f\n脈波周期揺らぎ：%f[s]\n呼吸数：%f[bpm]\n呼吸の深さ：%f',P_rate_Chest, ave_N_PG_Chest, ave_N_NG_Chest, N_SG_Chest, ave_PGT_Chest, ave_NGT_Chest, ave_A_Chest, ave_Ptime_change_Chest, R_rate, R_depth)
        end
        
        
        %1呼吸波形分取り出し:Chestデータから取得した呼吸波形の範囲に対応するWristデータと時間軸情報
        Chest_time = sweep_time_Chest/10000; %ChestデータとWristデータのそれぞれの時間単位
        
        
        %データをexcelに保存
        head_num = data_num;
        head_num = head_num +59;
        head_num_str = num2str(head_num); %文字列に変換
        head = append('A',head_num_str);

 
        A = [P_rate_Chest ave_N_PG_Chest ave_N_NG_Chest N_SG_Chest ave_PGT_Chest ave_NGT_Chest ave_A_Chest ave_Ptime_change_Chest R_rate R_depth];
        writematrix(A,excel_name,'Range',head);
   
        disp('done');
       
    catch ME
        disp(ME)
    end
    clearvars -except data_num excel_name
end