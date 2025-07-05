


// filmler hariç çalışıyor 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:ip_tv/dataM3u/data.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IP TV',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF1E88E5),
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary:  Color(0xFF1E88E5),
          secondary:  Color(0xFF03DAC5),
          surface:  Color(0xFF1E1E1E),
          background:  Color(0xFF121212),
        ),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 6,
          color: const Color(0xFF1E1E1E),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E88E5),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        textTheme: ThemeData.dark().textTheme.copyWith(
          titleLarge:const TextStyle(fontWeight: FontWeight.w600),
          titleMedium:const TextStyle(fontWeight: FontWeight.w500),
        ),
        appBarTheme:const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      home:  const IPTVPlayerPage(),
    );
  }
}

class IPTVPlayerPage extends StatefulWidget {
  const IPTVPlayerPage({super.key});

  @override
  _IPTVPlayerPageState createState() => _IPTVPlayerPageState();
}

class _IPTVPlayerPageState extends State<IPTVPlayerPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  String _selectedCategory = 'Movies';
  String? _playingUrl;
  String _currentChannelName = '';
  bool _isFullScreen = false;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  final List<String> _categories = ['TV Channels', 'Sports', 'Sketches'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _selectedCategory = _categories[_tabController.index];
        _searchQuery = '';
        _searchController.clear();
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
        _searchController.clear();
      }
    });
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFullScreen && _playingUrl != null) {
      return _buildFullScreenPlayer();
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              pinned: true,
              floating: true,
              snap: true,
              title: _isSearching
                  ? TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search ${_selectedCategory}...',
                        hintStyle: const TextStyle(color: Colors.white60),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    )
                  : const Text('IP TV'),
              actions: [
                IconButton(
                  icon: Icon(_isSearching ? Icons.close : Icons.search),
                  onPressed: _toggleSearch,
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Theme.of(context).colorScheme.secondary,
                indicatorWeight: 3,
                tabs: _categories.map((category) => Tab(text: category)).toList(),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            // Video player (if active)
            if (_playingUrl != null && !_isFullScreen)
              Card(
                margin: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Chewie(
                            controller: _chewieController!,
                          ),
                        ),
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: FloatingActionButton.small(
                            heroTag: 'fullscreen',
                            onPressed: _toggleFullScreen,
                            child:  Icon(Icons.fullscreen),
                            backgroundColor: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        _currentChannelName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

            // Content grid
            Expanded(child: _buildContent()),
          ],
        ),
      ),
      // FAB for recommended content
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show dialog with recommended content
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Editor\'s Picks'),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    final List<Map<String, String>> allContent = [...channels, ...tvChannels];
                    final recommendedIndex = (index * 7) % allContent.length; // Pick some scattered items
                    final item = allContent[recommendedIndex];
                    
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(item['logo'] ?? ''),
                      ),
                      title: Text(item['name'] ?? ''),
                      onTap: () {
                        Navigator.pop(context);
                        _playVideo(item['url'] ?? '', item['name'] ?? '');
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.recommend),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  Widget _buildFullScreenPlayer() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Chewie(
                controller: _chewieController!,
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.fullscreen_exit),
              color: Colors.white,
              onPressed: _toggleFullScreen,
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: Text(
              _currentChannelName,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    List<Map<String, String>> items;

    // Select the appropriate list based on the category
    switch (_selectedCategory) {
      case 'TV Channels':
        items = tvChannels;
        break;
      case 'Sports':
        items = channels;
        break;
 
      default:
        items = channels; // Default to channels instead of films
        break;
    }

    // Filter items based on search query
    if (_searchQuery.isNotEmpty) {
      items = items.where((item) {
        return (item['name'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // If no items match the search
    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No results found',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Group items by categories (for TV channels)
    if (_selectedCategory == 'TV Channels') {
      Map<String, List<Map<String, String>>> groupedChannels = {};
      
      // Extract categories from comments in items
      for (var channel in items) {
        String category = 'General';
        
        // Find items that have the same index neighbors with comments
        int index = tvChannels.indexOf(channel);
        if (index > 0 && index < tvChannels.length) {
          // Look for comment pattern above this item (check up to 3 items before)
          for (int i = 1; i <= 3; i++) {
            if (index - i >= 0) {
              var prevChannel = tvChannels[index - i];
              // If the previous item has a name that starts with // it's likely a comment
              if ((prevChannel['name'] ?? '').contains('//')) {
                category = (prevChannel['name'] ?? '').replaceAll('//', '').trim();
                break;
              }
            }
          }
        }
        
        // For the specific structure in our data where comments are embedded
        if (index > 0) {
          if (index <= 8) category = 'TRT Channels';
          else if (index <= 17) category = 'News';
          // ignore: curly_braces_in_flow_control_structures
          else if (index <= 21) category = 'Documentary';
          else if (index <= 26) category = 'General';
          else if (index <= 30) category = 'Children';
          else if (index <= 34) category = 'Music';
          else category = 'Relaxation';
        }
        
        if (!groupedChannels.containsKey(category)) {
          groupedChannels[category] = [];
        }
        groupedChannels[category]!.add(channel);
      }

      // Build expandable sections for categories
      return ListView.builder(
        itemCount: groupedChannels.keys.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          String category = groupedChannels.keys.elementAt(index);
          List<Map<String, String>> categoryChannels = groupedChannels[category]!;
          
          return ExpansionTile(
            title: Text(
              category,
              style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary),
            ),
            initiallyExpanded: index == 0, // Open first category by default
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: categoryChannels.length,
                itemBuilder: (context, idx) {
                  final channel = categoryChannels[idx];
                  return _buildItemCard(channel);
                },
              ),
            ],
          );
        },
      );
    }

    // Default grid view for other categories
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildItemCard(item);
      },
    );
  }

  Widget _buildItemCard(Map<String, String> item) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          _playVideo(item['url'] ?? '', item['name'] ?? '');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    item['logo'] ?? '',
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[800],
                        child: Center(child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        )),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[900],
                      child: Icon(Icons.error, color: Colors.red),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black87, Colors.transparent],
                        ),
                      ),
                      child: Text(
                        item['name'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _playVideo(String url, String name) {
    if (_playingUrl == url) return;

    // Clean up previous controllers
    _videoPlayerController?.dispose();
    _chewieController?.dispose();

    setState(() {
      _currentChannelName = name;
      // Set these to null while initializing to avoid using disposed controllers
      _videoPlayerController = null;
      _chewieController = null;
      _playingUrl = null;
    });

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Loading $name...'),
        duration: const Duration(seconds: 2),
      ),
    );

    // Initialize the video player
    _videoPlayerController = VideoPlayerController.network(url);

    // Add initialization listener
    _videoPlayerController!.initialize().then((_) {
      // Check if the controller is disposed before proceeding
      if (!_videoPlayerController!.value.isInitialized) return;

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        aspectRatio: 16 / 9,
        autoPlay: true,
        looping: true,
        allowFullScreen: true,
        allowMuting: true,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 42),
                const SizedBox(height: 8),
                const Text('Stream error: The channel may be offline',
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('Technical details: $errorMessage',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _playVideo(url, name); // Retry
                  },
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        },
      );

      // Update state only if everything initialized correctly
      if (mounted) {
        setState(() {
          _playingUrl = url;
        });
      }
    }).catchError((error) {
      // Handle initialization error
      if (mounted) {
        setState(() {
          _currentChannelName = '$name (Unavailable)';
          _playingUrl = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not load stream: $name'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Try Again',
              onPressed: () => _playVideo(url, name),
              textColor: Colors.white,
            ),
          ),
        );
      }
      print('Video initialization error: $error');
    });
  }
}






