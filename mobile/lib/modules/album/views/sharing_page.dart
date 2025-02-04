import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:immich_mobile/constants/hive_box.dart';
import 'package:immich_mobile/modules/album/providers/shared_album.provider.dart';
import 'package:immich_mobile/modules/album/ui/sharing_sliver_appbar.dart';
import 'package:immich_mobile/routing/router.dart';
import 'package:immich_mobile/shared/services/cache.service.dart';
import 'package:immich_mobile/utils/image_url_builder.dart';
import 'package:openapi/api.dart';

class SharingPage extends HookConsumerWidget {
  const SharingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var box = Hive.box(userInfoBox);
    var thumbnailRequestUrl = '${box.get(serverEndpointKey)}/asset/thumbnail';
    final List<AlbumResponseDto> sharedAlbums = ref.watch(sharedAlbumProvider);
    final CacheService cacheService = ref.watch(cacheServiceProvider);

    useEffect(
      () {
        ref.read(sharedAlbumProvider.notifier).getAllSharedAlbums();
        return null;
      },
      [],
    );

    _buildAlbumList() {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final album = sharedAlbums[index];

            return ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  width: 60,
                  height: 60,
                  memCacheHeight: 200,
                  fit: BoxFit.cover,
                  cacheManager:
                      cacheService.getCache(CacheType.sharedAlbumThumbnail),
                  imageUrl: getAlbumThumbnailUrl(album),
                  cacheKey: album.albumThumbnailAssetId,
                  httpHeaders: {
                    "Authorization": "Bearer ${box.get(accessTokenKey)}"
                  },
                  fadeInDuration: const Duration(milliseconds: 200),
                ),
              ),
              title: Text(
                sharedAlbums[index].albumName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              onTap: () {
                AutoRouter.of(context)
                    .push(AlbumViewerRoute(albumId: sharedAlbums[index].id));
              },
            );
          },
          childCount: sharedAlbums.length,
        ),
      );
    }

    _buildEmptyListIndication() {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // if you need this
              side: const BorderSide(
                color: Colors.grey,
                width: 1,
              ),
            ),
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 5.0, bottom: 5),
                    child: Icon(
                      Icons.offline_share_outlined,
                      size: 50,
                      // color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'sharing_page_empty_list',
                      style: Theme.of(context).textTheme.headline3,
                    ).tr(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'sharing_page_description',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ).tr(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SharingSliverAppBar(),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            sliver: SliverToBoxAdapter(
              child: const Text(
                "sharing_page_album",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ).tr(),
            ),
          ),
          sharedAlbums.isNotEmpty
              ? _buildAlbumList()
              : _buildEmptyListIndication()
        ],
      ),
    );
  }
}
