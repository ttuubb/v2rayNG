import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/server_config.dart';
import '../viewmodels/server_list_viewmodel.dart';
import '../viewmodels/server_detail_viewmodel.dart';

class ServerDetailPage extends StatefulWidget {
  final ServerConfig? server; // 如果为null，则是添加新服务器

  const ServerDetailPage({Key? key, this.server}) : super(key: key);

  @override
  State<ServerDetailPage> createState() => _ServerDetailPageState();
}

class _ServerDetailPageState extends State<ServerDetailPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _portController;
  String _selectedProtocol = 'vmess';
  bool _isEnabled = true;
  final Map<String, dynamic> _settings = {};

  @override
  void initState() {
    super.initState();
    // 如果是编辑模式，初始化表单数据
    if (widget.server != null) {
      _nameController = TextEditingController(text: widget.server!.name);
      _addressController = TextEditingController(text: widget.server!.address);
      _portController = TextEditingController(text: widget.server!.port.toString());
      _selectedProtocol = widget.server!.protocol;
      _isEnabled = widget.server!.enabled;
      _settings.addAll(widget.server!.settings);
    } else {
      _nameController = TextEditingController();
      _addressController = TextEditingController();
      _portController = TextEditingController(text: '1080');
    }
  }

  @override
  void dispose() {
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 服务器详情表单
            // 这里根据实际需求添加表单字段
          ],
        ),
      ),
    );
  }

  Widget _buildProtocolSettings() {
    // 这里可以根据不同的协议类型显示不同的设置选项
    // 简化版本，实际应用中可以扩展
    switch (_selectedProtocol) {
      case 'vmess':
        return _buildVMessSettings();
      case 'shadowsocks':
        return _buildShadowsocksSettings();
      default:
        return const SizedBox.shrink();
    }
  }

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

  Widget _buildShadowsocksSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Shadowsocks 设置', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
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