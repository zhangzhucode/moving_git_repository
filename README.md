作者: zhangzhu /zhu.zhang.cn@outlook.com
时间: 2025-04-02

功能总结:
该脚本用于管理单个项目的本地仓库和远程仓库的同步。
脚本会检查本地仓库是否需要更新，并根据需要从源仓库拉取更新或推送到目标仓库。
如果更新过程中出现错误，脚本会输出相应的错误信息。
最后，脚本会输出本地仓库和目标仓库的更新结果。
注意：本地环境，需要用户提前在服务器上完成密钥的绑定

功能总结 (English):
This script is used to manage the synchronization of a single project's local and remote repositories.
The script checks if the local repository needs to be updated and pulls updates from the source repository or pushes updates to the target repository as needed.
If an error occurs during the update process, the script will output the corresponding error message.
Finally, the script will output the update results for the local and target repositories.
Note: The local environment requires users to have completed key binding on the server in advance.

使用说明:
1. 编辑脚本文件，将项目信息添加到 `projects` 数组中。
2. 每个项目包含以下字段：
- local_repo: 本地仓库名称
- source_remote: 源远程仓库地址
- target_remote: 目标远程仓库地址
- branch_name: 源仓库的分支名称
- target_branch_name: 目标仓库的分支名称
3. 运行脚本:
./moving_a_git_repository.sh

英文使用说明:
1. Edit the script file and add project information to the `projects` array.
2. Each project contains the following fields:
- local_repo: Local repository name
- source_remote: Source remote repository URL
- target_remote: Target remote repository URL
- branch_name: Branch name in the source repository
- target_branch_name: Branch name in the target repository
3. Run the script:
./moving_a_git_repository.sh
