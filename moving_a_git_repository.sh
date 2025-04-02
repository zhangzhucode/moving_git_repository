#!/bin/bash

# 作者: zhangzhu /zhu.zhang.cn@outlook.com
# 时间: 2025-04-02
# 功能总结:
# 该脚本用于管理单个项目的本地仓库和远程仓库的同步。

# 脚本会检查本地仓库是否需要更新，并根据需要从源仓库拉取更新或推送到目标仓库。
# 如果更新过程中出现错误，脚本会输出相应的错误信息。
# 最后，脚本会输出本地仓库和目标仓库的更新结果。
# 注意：本地环境，需要用户提前在服务器上完成密钥的绑定


# 默认参数值
local_repo=""
source_remote=""
target_remote=""
branch_name=""
target_branch_name=""


# 检查必填参数
if [ -z "$local_repo" ] || [ -z "$source_remote" ] || [ -z "$target_remote" ] || [ -z "$branch_name" ] || [ -z "$target_branch_name" ]; then
    echo "请提供所有必需的参数:"
    echo "  -l, --local-repo: 本地仓库名称"
    echo "  -s, --source-remote: 源远程仓库地址"
    echo "  -t, --target-remote: 目标远程仓库地址"
    echo "  -b, --branch-name: 源仓库的分支名称"
    echo "  -T, --target-branch-name: 目标仓库的分支名称"
    exit 1
fi

# 创建本地文件夹（如果不存在）
if [ ! -d "$local_repo" ]; then
    mkdir -p "$local_repo"
    echo "本地文件夹 $local_repo 不存在，已创建。"
else
    echo "本地文件夹 $local_repo 已存在"
fi

# 进入本地仓库目录
cd "$local_repo" || { echo "无法进入本地文件夹 $local_repo"; exit 1; }

# 克隆源仓库（如果本地仓库为空）
if [ ! -d ".git" ]; then
    echo "本地仓库路径 $local_repo 为空，开始克隆源仓库..."
    git clone -b "$branch_name" "$source_remote" .

    # 添加源仓库和目标仓库的远程地址
    git remote add source "$source_remote"
    git remote add target "$target_remote"
else
    echo "本地仓库 $local_repo 不为空。"
fi

# 检查并更新本地仓库
git fetch source
source_remote_commit=$(git rev-parse source/"$branch_name")
local_commit=$(git rev-parse "$branch_name")
if [ "$source_remote_commit" != "$local_commit" ]; then
    echo "检测到本地仓库不是最新的，本地提交: $local_commit..."
    echo "检测到服务器仓库，$source_remote_commit..."

    git pull source "$branch_name"
    if [ $? -ne 0 ]; then
        echo "本地仓库更新错误！"
        exit 1
    else
        echo "本地仓库更新成功！"
    fi
else
    echo "本地仓库 不需要更新"
fi

# 检查并更新目标仓库
git fetch target
target_remote_commit=$(git rev-parse target/"$target_branch_name")
if [ "$local_commit" != "$target_remote_commit" ]; then
    echo "检测到本地仓库和目标仓库不一致，开始更新目标仓库..."
    git push target "$target_branch_name"
    if [ $? -ne 0 ]; then
        echo "目标仓库更新错误！"
        exit 1
    else
        echo "目标仓库更新成功！"
    fi
else
    echo "本地仓库和目标仓库版本一致。"
fi