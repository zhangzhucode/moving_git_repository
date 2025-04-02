#!/bin/bash

# 作者: zhangzhu /zhu.zhang.cn@outlook.com
# 时间: 2025-04-02
# 功能总结:
# 该脚本用于管理多个项目的本地仓库和远程仓库的同步。

# 每个项目包含本地仓库名称、源远程仓库地址、目标远程仓库地址、源分支名称和目标分支名称。
# 脚本会遍历每个项目，检查本地仓库是否需要更新，并根据需要从源仓库拉取更新或推送到目标仓库。
# 如果更新过程中出现错误，脚本会跳到下一个项目继续处理。
# 最后，脚本会输出所有项目的处理结果总结。
# 注意：本地环境，需要用户提前在服务器上完成密钥的绑定

# Each project contains the following fields:
# 1. local_repo: Local repository name
# 2. source_remote: Source remote repository URL
# 3. target_remote: Target remote repository URL
# 4. branch_name: Branch name in the source repository
# 5. target_branch_name: Branch name in the target repository

# 定义项目数组
# 每个项目包含以下字段：
# 1. local_repo: 本地仓库名称
# 2. source_remote: 源远程仓库地址
# 3. target_remote: 目标远程仓库地址
# 4. branch_name: 源仓库的分支名称
# 5. target_branch_name: 目标仓库的分支名称
declare -a projects=(
#    "project2 git@xx.xxxx.com:project2/repo.git git@xxxx.com:zhangzhu/xxxx/repo.git dev dev"
    # 可以继续添加更多项目
)

# 初始化项目计数器
project_count=0

# 定义结果数组
declare -a results

# 遍历每个项目
for project in "${projects[@]}"; do
    # 增加项目计数器
    ((project_count++))

    # 解析项目信息
    IFS=' ' read -r local_repo source_remote target_remote branch_name target_branch_name <<< "$project"

    echo "处理项目 $project_count: $local_repo"

    # 创建本地文件夹（如果不存在）
    if [ ! -d "$local_repo" ]; then
        mkdir -p "$local_repo"
        echo "[$local_repo] 本地文件夹 $local_repo 不存在，已创建。"
    else
        echo "[$local_repo] 本地文件夹 $local_repo 已存在"
    fi

    # 进入本地仓库目录
    cd "$local_repo" || { echo "[$local_repo] 无法进入本地文件夹 $local_repo"; results+=("[$local_repo] 处理错误"); continue; }

    # 克隆源仓库（如果本地仓库为空）
    if [ ! -d ".git" ]; then
        echo "[$local_repo] 本地仓库路径 $local_repo 为空，开始克隆源仓库..."
        git clone -b "$branch_name" "$source_remote" .

        # 添加源仓库和目标仓库的远程地址
        git remote add source "$source_remote"
        git remote add target "$target_remote"
    else
        echo "[$local_repo] 本地仓库 $local_repo 不为空。"
    fi

    # 检查并更新本地仓库
    git fetch source
    source_remote_commit=$(git rev-parse source/"$branch_name")
    local_commit=$(git rev-parse "$branch_name")
    if [ "$source_remote_commit" != "$local_commit" ]; then
        echo "[$local_repo] 检测到本地仓库不是最新的，本地提交: $local_commit..."
        echo "[$local_repo] 检测到源仓库的最新提交: $source_remote_commit..."

        git pull source "$branch_name"
        if [ $? -ne 0 ]; then
            echo "[$local_repo] 本地仓库更新错误！"
            results+=("[$local_repo] 更新错误")
            continue
        else
            echo "[$local_repo] 本地仓库更新成功！"
            results+=("[$local_repo] 已经更新")
        fi
    else
        echo "[$local_repo] 本地仓库 不需要更新"
        results+=("[$local_repo] 不需要更新")
    fi

    # 检查并更新目标仓库
    git fetch target
    target_remote_commit=$(git rev-parse target/"$target_branch_name")
    if [ "$local_commit" != "$target_remote_commit" ]; then
        echo "[$local_repo] 检测到本地仓库和目标仓库不一致，开始更新目标仓库..."
        git push target "$target_branch_name"
        if [ $? -ne 0 ]; then
            echo "[$local_repo] 目标仓库更新错误！"
            results+=("[$local_repo] 更新错误")
            continue
        else
            echo "[$local_repo] 目标仓库更新成功！"
            results+=("[$local_repo] 已经更新")
        fi
    else
        echo "[$local_repo] 本地仓库和目标仓库版本一致。"
        results+=("[$local_repo] 不需要更新")
    fi

    # 返回上一级目录
    cd ..
done

# 输出所有项目的处理结果
echo "所有项目的处理结果总结："
for result in "${results[@]}"; do
    echo "$result"
done
