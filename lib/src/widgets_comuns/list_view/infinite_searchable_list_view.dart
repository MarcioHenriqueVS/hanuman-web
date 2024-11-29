import 'package:flutter/material.dart';
import 'package:refresh_loadmore/refresh_loadmore.dart';

class InfiniteSearchableListView<T> extends StatefulWidget {
  final Future<void> Function()? onRefresh;
  final Future<void> Function()? loadMoreData;
  final void Function() searchListener;
  final void Function()? scrollListener;
  final ScrollController scrollController;
  final bool hasMoreData;
  final bool buscandoMais;
  final Widget child;
  final String? labelText;
  final bool erroBuscaInicial;
  final bool semDados;
  final bool buscando;
  final String emptyDataMessage;
  final TextEditingController searchController;
  const InfiniteSearchableListView(
      {super.key,
      this.onRefresh,
      this.loadMoreData,
      required this.scrollController,
      required this.hasMoreData,
      required this.buscandoMais,
      required this.child,
      this.labelText,
      required this.searchListener,
      this.scrollListener,
      required this.buscando,
      required this.erroBuscaInicial,
      required this.semDados,
      required this.emptyDataMessage,
      required this.searchController});

  @override
  State<InfiniteSearchableListView> createState() =>
      _InfiniteSearchableListViewState();
}

class _InfiniteSearchableListViewState
    extends State<InfiniteSearchableListView> {
  @override
  void initState() {
    widget.searchController.addListener(widget.searchListener);
    if (widget.scrollListener != null) {
      widget.scrollController.addListener(widget.scrollListener!);
    }
    super.initState();
  }

  @override
  void dispose() {
    widget.searchController.dispose();
    widget.scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.erroBuscaInicial
        ? const Center(
            child: Text('Erro, atualize a tela.'),
          )
        : widget.semDados
            ? Center(
                child: Text(widget.emptyDataMessage),
              )
            : widget.buscando
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshLoadmore(
                    scrollController: widget.scrollController,
                    onRefresh: widget.onRefresh,
                    onLoadmore: widget.loadMoreData,
                    isLastPage: !widget.hasMoreData,
                    noMoreWidget: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Você chegou ao fim',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: TextFormField(
                                    controller: widget.searchController,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.grey[900],
                                      labelText: widget.labelText,
                                      labelStyle:
                                          TextStyle(color: Colors.grey[600]),
                                      // suffixIcon: Icon(
                                      //   Icons.search_outlined,
                                      //   color: Colors.grey[600]!,
                                      // ),
                                      prefixIcon: Icon(
                                        Icons.search_outlined,
                                        color: Colors.grey[600]!,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            25), // Raio da borda arredondada
                                        borderSide:
                                            BorderSide.none, // Remove a borda
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: const Icon(
                                  Icons.filter_list_outlined,
                                  size: 35,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                        widget.child,
                        widget.buscandoMais
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  );
  }
}
