# 以前の設定 (2019)
# export LD_LIBRARY_PATH=/usr/lib/cuda/lib64:$LD_LIBRARY_PATH
# memo uninstallするなら
# run cuda-uninstaller in /usr/local/cuda-11.1/bin

# 2022 複数のcuda+cudnnのversionをupdate-alternativesで管理
# cuda-10.1, cuda-10.2, cuda-11.7
# update-alternatives --config cudaで変更
export PATH=/usr/local/cuda/bin${PATH+:${PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda/lib:/usr/local/cuda-11.7/lib64:/usr/local/cuda-10.2/lib64:/usr/local/cuda-10.1/lib64${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}}
