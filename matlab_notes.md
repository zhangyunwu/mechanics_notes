# matlab 常用

## 离散数据求导
位移求导得速度
```matlab
[~, velocity] = gradient(displacement, dt)
```

## 离散数据积分
速度积分为位移
