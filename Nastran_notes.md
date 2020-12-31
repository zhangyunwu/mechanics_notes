# Nastran notes

# 建模
## 集中质量/协调质量

## 阻尼

- **结构阻尼**（structral damping）

    结构阻尼力与位移成正比
    $$f_s=iGku$$

    其中：
    - $G$为结构阻尼系数
    - $k$为刚度
    - $u$为位移
    - $i=\sqrt{(-1)}$，表示相位改变$90^\circ$

- **粘性阻尼**（viscous damping）
    粘性阻尼力与速度成正比
    $$f_v=c\dot{u}=i\omega cu$$

    其中：
    - $c$为粘性阻尼系数
    - $\dot{u}$为速度
- **阻尼比**
    $$\xi=\frac{G}{2}=\frac{1}{2Q}$$

    其中$Q$为动态放大因子（放大系数、质量系数）

另请参考：[autodesk inventor nastran](https://knowledge.autodesk.com/zh-hans/support/inventor-nastran/learn-explore/caas/CloudHelp/cloudhelp/2021/CHS/NINCAD-UsersGuide/files/GUID-A95DA0DE-C497-450F-B6AC-0C92F6E5DAEC-htm.html)

> github markdown不支持latex公式渲染，Chrome浏览器可安装`MathJax Plugin for Github`插件。
> 或将文件下载后用其他方式渲染（例如直接vscode）。

# 模态分析

NX软件（或其他任意软件）画网格得到有限元模型，然后**新建仿真**，**解算方案**中**解算类型**选择为**SOL 103 实特征值**

![解算类型](https://github.com/zhangyunwu/mechanics_notes/blob/main/images/%E8%A7%A3%E7%AE%97%E7%B1%BB%E5%9E%8B%E9%80%89%E6%8B%A9.png)

然后设置边界条件，提交计算即可。

要设置输出的模态阶数，可编辑**Subcase**，修改**Lanczos特征值方法**的**Lanczos数据**，**所需模态数**即为模态分析输出的模态阶数。

![编辑Subcase](https://github.com/zhangyunwu/mechanics_notes/blob/main/images/%E7%BC%96%E8%BE%91Subcase.png)
![修改模态阶数](https://github.com/zhangyunwu/mechanics_notes/blob/main/images/%E4%BF%AE%E6%94%B9%E6%A8%A1%E6%80%81%E9%98%B6%E6%95%B0.png)

表现在卡片中为：
```
$*  Modeling Object: Real Eigenvalue - Lanczos1
$IGRL        SID      V1      V2      ND  MSGLVL  MAXSET  SHFSCL    NORM
EIGRL        101                      40       0       7            MASS
```

## 输出振型矩阵

在模态分析时可直接将振型矩阵数据输出到`.f06`文件中:

编辑**解算方案**-**工况控制**-**输出请求**，在对应输出变量中将**输出介质**修改为`PRINT`（默认为`PLOT`）

表现在卡片中为：
```
OUTPUT
DISPLACEMENT(PRINT,REAL) = ALL
```

![编辑解算方案](https://github.com/zhangyunwu/mechanics_notes/blob/main/images/%E7%BC%96%E8%BE%91%E8%A7%A3%E7%AE%97%E6%96%B9%E6%A1%88.png)
![修改输出介质](https://github.com/zhangyunwu/mechanics_notes/blob/main/images/%E4%BF%AE%E6%94%B9%E8%BE%93%E5%87%BA%E4%BB%8B%E8%B4%A8.png)

> 修改输出介质为`PRINT`后就能在`.f06`文件中找到振型数据，且不影响在后处理界面查看振型云图。

## 输出质量矩阵、刚度矩阵

首先按照常规模态分析步骤新建算例，然后添加**参数（PARAM）**：`PARAM,EXTOUT,DMIGPCH` 

表现在卡片中为：
```
OUTPUT
PARAM,EXTOUT,DMIGPCH
```

> 此参数在卡片中位于`OUTPUT`之后，而不是在`PARAM CARDS`位置。

![EXTOUT参数](https://github.com/zhangyunwu/mechanics_notes/blob/main/images/EXTOUT%E5%8F%82%E6%95%B0%E8%AE%BE%E7%BD%AE.png)

然后提交计算，模型的刚度矩阵、质量矩阵信息会保存在`.pch`文件中

`.pch`文件中的数据以稀疏矩阵方式存储，需要手动转换为常规矩阵形式的数据，见[Get_K_M.m](https://github.com/zhangyunwu/mechanics_notes/blob/main/Get_K_M.m)

> 此方法无法同时完成常规模态分析，因为这个时候软件并没有输出振型结果。
> 输出的质量矩阵、刚度矩阵不含边界条件，所以在建立算例时无需添加边界条件。

# 频域分析

## 输出频响函数矩阵
首先建立有限元模型后**新建仿真**，**解算方案**中**解算类型**选择为**SOL 108 直接频率响应函数**。

![SOL 108 直接频率响应函数](https://github.com/zhangyunwu/mechanics_notes/blob/main/images/SOL%20108%20%E7%9B%B4%E6%8E%A5%E9%A2%91%E7%8E%87%E5%93%8D%E5%BA%94%E5%87%BD%E6%95%B0.png)

然后完成模型阻尼和边界条件的设置。

再设置要输出的频响函数矩阵的对应自由度（一般没有必要输出全部自由度的数据），也就是从哪些自由度输入、哪些自由度输出。

在NX **SOL 108 直接频率响应函数**中通过设置载荷来确定输入点的自由度。这里选择的载荷类型当然是单位力。

![SOL 108 载荷类型](https://github.com/zhangyunwu/mechanics_notes/blob/main/images/SOL%20108%20%E8%BD%BD%E8%8D%B7%E7%B1%BB%E5%9E%8B.png)

这里需要注意，软件中选择的单位力作用位置是节点，而我们需要的是具体到某个自由度，所以需要具体设置某个节点哪些自由度激励哪些自由度不激励。建议先将各单位力作用节点设置好集合（组），避免混乱。

![SOL 108 单位力设置](https://github.com/zhangyunwu/mechanics_notes/blob/main/images/SOL%20108%20%E5%8D%95%E4%BD%8D%E5%8A%9B%E8%AE%BE%E7%BD%AE.png)

再编辑输出参数，设置输出的自由度。先将需要输出响应的节点都放进一个集合（组）内。然后编辑**SubCase**-**输出请求**，设置对应物理量的**输出介质**为`PRINT`，**节点选择**直接引用前面设置好的组。

![SOL 108 输出请求](https://github.com/zhangyunwu/mechanics_notes/blob/main/images/SOL%20108%20%E8%BE%93%E5%87%BA%E8%AF%B7%E6%B1%82.png)

最后再设置需要输出的频点。
编辑**SubCase**-**扰动频率**，新建一个**扰动频率**建模对象，设置**频率列表**，软件可以设置多种频率列表格式，包括**个别频率（FREQ）**、**线性扫频（FREQ1）**、**对数扫频（FREQ2）**、**倍频程（FREQ）**等。此处以**线性扫频（FREQ1）**为例，线性扫频定义方式又有**步长**和**步数**两种。

![SOL 108 线性扫频](https://github.com/zhangyunwu/mechanics_notes/blob/main/images/SOL%20108%20%E7%BA%BF%E6%80%A7%E6%89%AB%E9%A2%91.png)

注意，这里设置步数为5000，实际得到的是5001个频点数据，$f=[0,500],step=0.1$，左右端点都包括。