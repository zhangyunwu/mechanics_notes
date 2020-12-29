# Nastran notes

## 输出质量矩阵、刚度矩阵

NX软件（或其他任意软件）画网格得到有限元模型，然后“新建仿真”，“解算方案”中“解算类型”选择为“SOL 103 实特征值” 

![解算类型](https://github.com/zhangyunwu/mechanics_notes/blob/main/images/%E8%A7%A3%E7%AE%97%E7%B1%BB%E5%9E%8B%E9%80%89%E6%8B%A9.png)

然后添加参数（PARAM）：`PARAM,EXTOUT,DMIGPCH` 

![EXTOUT参数](https://github.com/zhangyunwu/mechanics_notes/blob/main/images/EXTOUT%E5%8F%82%E6%95%B0%E8%AE%BE%E7%BD%AE.png)

然后提交计算，模型的刚度矩阵、质量矩阵信息会保存在`.pch`文件中

`.pch`文件中的数据以稀疏矩阵方式存储，需要手动转换为常规矩阵形式的数据