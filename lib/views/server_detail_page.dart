import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/server_config.dart';
import '../viewmodels/server_detail_viewmodel.dart';

/// 服务器详情页面
/// 用于添加新的服务器配置或编辑现有服务器配置
/// 支持多种代理协议（如VMess、Shadowsocks等）的配置管理
class ServerDetailPage extends StatefulWidget {
  /// 当前编辑的服务器配置，如果为null则表示添加新服务器
  final ServerConfig? server;
  
  const ServerDetailPage({Key? key, this.server}) : super(key: key);
  
  @override
  State<ServerDetailPage> createState() => _ServerDetailPageState();
}

/// 服务器详情页面状态类
/// 维护表单状态和服务器配置数据
class _ServerDetailPageState extends State<ServerDetailPage> {
  /// 表单的全局键，用于验证表单数据
  final _formKey = GlobalKey<FormState>();
  
  /// 服务器名称输入控制器
  late TextEditingController _nameController;
  
  /// 服务器地址输入控制器
  late TextEditingController _addressController;
  
  /// 端口号输入控制器
  late TextEditingController _portController;
  
  /// 当前选择的代理协议
  String _selectedProtocol = 'vmess';
  
  /// 服务器是否启用
  bool _isEnabled = true;
  
  /// 协议特定的设置参数
  final Map<String, dynamic> _settings = {};
  
  @override
  void initState() {
    super.initState();
    // 初始化表单数据，如果是编辑模式则填充现有数据
    if (widget.server != null) {
      _nameController = TextEditingController(text: widget.server!.name);
      _addressController = TextEditingController(text: widget.server!.address);
      _portController = TextEditingController(text: widget.server!.port.toString());
      _selectedProtocol = widget.server!.protocol;
      _isEnabled = widget.server!.enabled;
      _settings.addAll(widget.server!.settings);
    } else {
      // 新建模式下的默认值
      _nameController = TextEditingController();
      _addressController = TextEditingController();
      _portController = TextEditingController(text: '1080');
    }
  }
  
  @override
  void dispose() {
    // 释放控制器资源
    _nameController.dispose();
    _addressController.dispose();
    _portController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.server == null ? '添加服务器' : '编辑服务器'),
      ),
      // 添加悬浮保存按钮
      floatingActionButton: FloatingActionButton(
        onPressed: _saveServer,
        child: const Icon(Icons.save),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 服务器名称输入框
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '服务器名称',
                  hintText: '输入服务器名称',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入服务器名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // 服务器地址输入框
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: '服务器地址',
                  hintText: '输入服务器地址',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入服务器地址';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // 端口号输入框
              TextFormField(
                controller: _portController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '端口号',
                  hintText: '输入端口号',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入端口号';
                  }
                  final port = int.tryParse(value);
                  if (port == null || port <= 0 || port > 65535) {
                    return '请输入有效的端口号（1-65535）';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // 协议选择下拉框
              DropdownButtonFormField<String>(
                value: _selectedProtocol,
                decoration: const InputDecoration(
                  labelText: '代理协议',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'vmess', child: Text('VMess')),
                  DropdownMenuItem(value: 'shadowsocks', child: Text('Shadowsocks')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedProtocol = value;
                      _settings.clear(); // 切换协议时清空之前的设置
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              // 启用开关
              SwitchListTile(
                title: const Text('启用'),
                value: _isEnabled,
                onChanged: (value) {
                  setState(() {
                    _isEnabled = value;
                  });
                },
              ),
              // 根据选择的协议类型显示对应的设置选项
              _buildProtocolSettings(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveServer,
                child: const Text('保存配置'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 构建协议特定的设置界面
  /// 根据不同的协议类型返回对应的设置选项组件
  Widget _buildProtocolSettings() {
    switch (_selectedProtocol) {
      case 'vmess':
        return _buildVMessSettings();
      case 'shadowsocks':
        return _buildShadowsocksSettings();
      default:
        return const SizedBox.shrink();
    }
  }
  
  /// 构建VMess协议的设置界面
  Widget _buildVMessSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('VMess 设置', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: _settings['id'] as String? ?? '',
          decoration: const InputDecoration(
            labelText: 'ID',
            hintText: '输入VMess ID',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _settings['id'] = value;
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请输入VMess ID';
            }
            return null;
          },
        ),
      ],
    );
  }
  
  /// 构建Shadowsocks协议的设置界面
  /// 包含密码和加密方式的配置选项
  Widget _buildShadowsocksSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Shadowsocks 设置', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        // 密码输入框
        TextFormField(
          initialValue: _settings['password'] as String? ?? '',
          decoration: const InputDecoration(
            labelText: '密码',
            hintText: '输入Shadowsocks密码',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
          onChanged: (value) {
            _settings['password'] = value;
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '请输入密码';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        // 加密方式选择下拉框
        DropdownButtonFormField<String>(
          value: _settings['method'] as String? ?? 'aes-256-gcm',
          decoration: const InputDecoration(
            labelText: '加密方式',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'aes-256-gcm', child: Text('AES-256-GCM')),
            DropdownMenuItem(value: 'chacha20-poly1305', child: Text('ChaCha20-Poly1305')),
            DropdownMenuItem(value: 'aes-128-gcm', child: Text('AES-128-GCM')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _settings['method'] = value;
              });
            }
          },
        ),
      ],
    );
  }
  
  /// 保存服务器配置
  /// 验证表单数据，创建ServerConfig对象并通过ViewModel保存
  void _saveServer() {
    if (_formKey.currentState!.validate()) {
      final viewModel = Provider.of<ServerDetailViewModel>(context, listen: false);
      
      final serverConfig = ServerConfig(
        name: _nameController.text,
        address: _addressController.text,
        port: int.parse(_portController.text),
        protocol: _selectedProtocol,
        settings: _settings,
        enabled: _isEnabled,
      );
      
      viewModel.loadServer(serverConfig);
      viewModel.saveServer().then((_) {
        Navigator.pop(context);
      });
    }
  }
}