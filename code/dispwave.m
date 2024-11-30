% 必要な変数の初期化
clc
clear
close all

% データ番号を指定（適宜変更してください）
data_num = 23;

% 読み込むファイル名を設定
num_str = num2str(data_num); % 文字列に変換
currentDir = fileparts(mfilename('fullpath'));
% data/csv ディレクトリへのパスを作成
csvDir = fullfile(currentDir,'..','data', 'csv','20241116');
data_name_chest = fullfile(csvDir, append('B_', num_str, '.csv'));
disp(['読み込むファイル: ', data_name_chest]);

% CSVファイルからデータを読み込む
allChestdatafile = readmatrix(data_name_chest);

% データの範囲を指定して取得
row_Chest = allChestdatafile(23:10023, 2); % データの範囲と列を適宜調整してください

% 時間軸を作成
sweep_time_Chest = 9.35; % データ収集時間（秒）
X_Chest = linspace(0, sweep_time_Chest, length(row_Chest)); % 時間軸

% サンプリング周波数の計算
fs_Chest = length(row_Chest) / sweep_time_Chest; % サンプリング周波数 [Hz]
figure;
plot(X_Chest, row_Chest);
hold on;
% バンドパスフィルタの適用（0.9~5Hz）
filter_Chest = bandpass(row_Chest, [0.9, 5], fs_Chest, 'ImpulseResponse', 'iir');

% ピークの検出（下側ピークを検出するために信号を反転）
filter_Chest_inverted = -filter_Chest;

% 下側ピークの検出

[pks_Pulse_lower_Chest, locs_Pulse_lower_Chest] = findpeaks(filter_Chest_inverted, X_Chest, 'MinPeakHeight', 0.02);
pks_Pulse_lower_Chest = -pks_Pulse_lower_Chest; % 元の振幅に戻す


% 波形とピークをプロット
figure;
plot(X_Chest, filter_Chest);
hold on;

% 下側ピークを赤い逆三角形でプロット
plot(locs_Pulse_lower_Chest, pks_Pulse_lower_Chest, 'rv', 'MarkerFaceColor', 'r');

hold off;
xlabel('Time [s]');
ylabel('Amplitude');
title(['データ番号 ', num_str, ' のフィルタリングされた波形と下側ピーク']);
grid on;
legend('Filtered Signal', 'Lower Peaks');

% ピーク検出後
% ピーク検出後

