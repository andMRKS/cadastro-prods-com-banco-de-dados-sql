import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() => runApp(ProdutoApp());

class ProdutoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadastro de Produtos',
      home: CadastroProdutoScreen(),
    );
  }
}

// Modelo de Produto
class Produto {
  final int? id;
  final String nome;
  final double precoCompra;
  final double precoVenda;
  final int quantidade;
  final String descricao;
  final String categoria;
  final String imagemUrl;
  final bool ativo;
  final bool emPromocao;
  final double desconto;

  Produto({
    this.id,
    required this.nome,
    required this.precoCompra,
    required this.precoVenda,
    required this.quantidade,
    required this.descricao,
    required this.categoria,
    required this.imagemUrl,
    required this.ativo,
    required this.emPromocao,
    required this.desconto,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'precoCompra': precoCompra,
      'precoVenda': precoVenda,
      'quantidade': quantidade,
      'descricao': descricao,
      'categoria': categoria,
      'imagemUrl': imagemUrl,
      'ativo': ativo ? 1 : 0,
      'emPromocao': emPromocao ? 1 : 0,
      'desconto': desconto,
    };
  }

  factory Produto.fromMap(Map<String, dynamic> map) {
    return Produto(
      id: map['id'],
      nome: map['nome'],
      precoCompra: map['precoCompra'],
      precoVenda: map['precoVenda'],
      quantidade: map['quantidade'],
      descricao: map['descricao'],
      categoria: map['categoria'],
      imagemUrl: map['imagemUrl'],
      ativo: map['ativo'] == 1,
      emPromocao: map['emPromocao'] == 1,
      desconto: map['desconto'],
    );
  }
}

// Banco de dados
class ProdutoDatabase {
  static final ProdutoDatabase _instance = ProdutoDatabase._internal();
  factory ProdutoDatabase() => _instance;
  ProdutoDatabase._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'produtos.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE produtos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT,
        precoCompra REAL,
        precoVenda REAL,
        quantidade INTEGER,
        descricao TEXT,
        categoria TEXT,
        imagemUrl TEXT,
        ativo INTEGER,
        emPromocao INTEGER,
        desconto REAL
      )
    ''');
  }

  Future<int> insertProduto(Produto produto) async {
    final db = await database;
    return await db.insert('produtos', produto.toMap());
  }

  Future<List<Produto>> getProdutos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('produtos');
    return List.generate(maps.length, (i) => Produto.fromMap(maps[i]));
  }

  Future<int> deleteProduto(int id) async {
    final db = await database;
    return await db.delete(
      'produtos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

// Tela de Cadastro
class CadastroProdutoScreen extends StatefulWidget {
  @override
  _CadastroProdutoScreenState createState() => _CadastroProdutoScreenState();
}

class _CadastroProdutoScreenState extends State<CadastroProdutoScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _precoCompraController = TextEditingController();
  final TextEditingController _precoVendaController = TextEditingController();
  final TextEditingController _quantidadeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _imagemUrlController = TextEditingController();

  String _categoria = 'Eletrônico';
  bool _produtoAtivo = true;
  bool _emPromocao = false;
  double _desconto = 0;

  final List<String> _categorias = ['Eletrônico', 'Alimento', 'Roupas', 'Outros'];

  Future<void> _cadastrarProduto() async {
    if (_formKey.currentState!.validate()) {
      final novoProduto = Produto(
        nome: _nomeController.text,
        precoCompra: double.parse(_precoCompraController.text),
        precoVenda: double.parse(_precoVendaController.text),
        quantidade: int.parse(_quantidadeController.text),
        descricao: _descricaoController.text,
        categoria: _categoria,
        imagemUrl: _imagemUrlController.text,
        ativo: _produtoAtivo,
        emPromocao: _emPromocao,
        desconto: _desconto,
      );

      await ProdutoDatabase().insertProduto(novoProduto);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ListaProdutosScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastrar Produto')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _precoCompraController,
                decoration: InputDecoration(labelText: 'Preço de compra'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _precoVendaController,
                decoration: InputDecoration(labelText: 'Preço de venda'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _quantidadeController,
                decoration: InputDecoration(labelText: 'Quantidade'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _descricaoController,
                decoration: InputDecoration(labelText: 'Descrição'),
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _categoria,
                decoration: InputDecoration(labelText: 'Categoria'),
                items: _categorias.map((String cat) {
                  return DropdownMenuItem<String>(
                    value: cat,
                    child: Text(cat),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _categoria = value!),
              ),
              TextFormField(
                controller: _imagemUrlController,
                decoration: InputDecoration(labelText: 'URL da Imagem'),
              ),
              SizedBox(height: 10),
              _imagemUrlController.text.isEmpty
                  ? SizedBox()
                  : Image.network(
                      _imagemUrlController.text,
                      height: 100,
                      errorBuilder: (context, error, stackTrace) =>
                          Text('Erro ao carregar imagem'),
                    ),
              SwitchListTile(
                title: Text('Produto Ativo'),
                value: _produtoAtivo,
                onChanged: (val) => setState(() => _produtoAtivo = val),
              ),
              CheckboxListTile(
                title: Text('Em Promoção'),
                value: _emPromocao,
                onChanged: (val) => setState(() => _emPromocao = val!),
              ),
              Text('Desconto: ${_desconto.round()}%'),
              Slider(
                value: _desconto,
                min: 0,
                max: 100,
                divisions: 20,
                label: _desconto.round().toString(),
                onChanged: (val) => setState(() => _desconto = val),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _cadastrarProduto,
                child: Text('Cadastrar Produto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Tela de Lista de Produtos
class ListaProdutosScreen extends StatelessWidget {
  final ProdutoDatabase dbHelper = ProdutoDatabase();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lista de Produtos')),
      body: FutureBuilder<List<Produto>>(
        future: dbHelper.getProdutos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final produtos = snapshot.data ?? [];
          return ListView.builder(
            itemCount: produtos.length,
            itemBuilder: (context, index) {
              final produto = produtos[index];
              return ListTile(
                leading: Image.network(
                  produto.imagemUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.image_not_supported),
                ),
                title: Text(produto.nome),
                subtitle: Text('R\$ ${produto.precoVenda.toStringAsFixed(2)}'),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await dbHelper.deleteProduto(produto.id!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Produto excluído com sucesso!')),
                    );
                    (context as Element).reassemble();
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DetalhesProdutoScreen(produto: produto),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// Tela de Detalhes do Produto
class DetalhesProdutoScreen extends StatelessWidget {
  final Produto produto;

  DetalhesProdutoScreen({required this.produto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalhes do Produto')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                produto.imagemUrl,
                height: 200,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.image_not_supported, size: 100),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.check_circle,
                    color: produto.ativo ? Colors.green : Colors.grey),
                SizedBox(width: 8),
                Text(
                  produto.ativo ? 'Produto Ativo' : 'Produto Inativo',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.local_offer,
                    color: produto.emPromocao ? Colors.orange : Colors.grey),
                SizedBox(width: 8),
                Text(
                  produto.emPromocao ? 'Em Promoção' : 'Preço Normal',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            Divider(height: 30),
            Text('Nome: ${produto.nome}', style: TextStyle(fontSize: 18)),
            Text('Categoria: ${produto.categoria}', style: TextStyle(fontSize: 18)),
            Text('Descrição:', style: TextStyle(fontSize: 18)),
            Text(produto.descricao, style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Preço de Compra: R\$ ${produto.precoCompra.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 16)),
            Text('Preço de Venda: R\$ ${produto.precoVenda.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 16)),
            Text('Quantidade: ${produto.quantidade}',
                style: TextStyle(fontSize: 16)),
            Text('Desconto: ${produto.desconto.toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
