% 必要な変数の初期化
clc
clear
close all

% データ番号を指定（適宜変更してください）
data_num = 1;

% 読み込むファイル名を設定
num_str = num2str(data_num); % 文字列に変換
currentDir = fileparts(mfilename('fullpath'));
% data/csv ディレクトリへのパスを作成
csvDir = fullfile(currentDir,'..','data', 'csv','20241116');
data_name_face = fullfile(csvDir, append('B_', num_str, '.csv'));
disp(['読み込むファイル: ', data_name_face]);

% CSVファイルからデータを読み込む
allfacedatafile = readmatrix(data_name_face);

% データの範囲を指定して取得
row_face = allfacedatafile(23:10023, 2); % データの範囲と列を適宜調整してください

% 時間軸を作成
sweep_time_face = 9.37; % データ収集時間（秒）
X_face = linspace(0, sweep_time_face, length(row_face)); % 時間軸

% サンプリング周波数の計算
fs_face = length(row_face) / sweep_time_face; % サンプリング周波数 [Hz]

figure;
plot(X_face, row_face);
hold on;

hold off;
xlabel('Time [s]');
ylabel('Amplitude');
title(['データ番号 ', num_str, ' のフィルタリングされた波形と下側ピーク']);
grid on;

% バンドパスフィルタの適用（0-0.9Hz）
[filter_face, e] = lowpass(row_face,0.9,fs_face,'ImpulseResponse','iir');%バンドパス0~0.9Hz

figure;
plot(X_face, filter_face);
hold on;

hold off;
xlabel('Time [s]');
ylabel('Amplitude');
title(['データ番号 ', num_str, ' のフィルタリングされた波形と下側ピーク']);
grid on;

ave_dis = mean(filter_face)



