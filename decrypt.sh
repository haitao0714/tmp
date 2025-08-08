#!/bin/bash

# 脚本默认在出错时立即退出
set -e

# --- 配置 ---
SOURCE_DIR="." 
# --- End of 配置 ---

# 检查环境变量
if [ -z "$DECRYPTION_KEY" ]; then
    echo "::error::DECRYPTION_KEY 环境变量未设置！"
    exit 1
fi

echo "开始解密 '$SOURCE_DIR' 目录下的所有 .enc 文件..."

# 查找并解密文件
find "$SOURCE_DIR" -type f -name "*.enc" -print0 | while IFS= read -r -d $'\0' file; do
    decrypted_file="${file%.enc}"
    echo "  -> 正在解密 $file..."

    # 解密命令，错误会因为 set -e 而导致脚本退出
    openssl aes-256-cbc -d -salt \
      -in "$file" \
      -out "$decrypted_file" \
      -pass env:DECRYPTION_KEY
done

# 检查是否至少有一个文件被解密
# 如果 find 没有找到任何 .enc 文件，脚本不应该报错
if ! find "$SOURCE_DIR" -type f -name "*.py" -print -quit | grep -q .; then
    echo "::warning::没有找到任何加密文件 (.enc) 来解密，或者解密后没有产生任何 .py 文件。"
fi

echo "所有文件解密完成。"