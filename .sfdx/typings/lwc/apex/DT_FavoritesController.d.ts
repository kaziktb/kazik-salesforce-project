declare module "@salesforce/apex/DT_FavoritesController.checkFavorite" {
  export default function checkFavorite(param: {jobOfferId: any, userId: any}): Promise<any>;
}
declare module "@salesforce/apex/DT_FavoritesController.deleteFavorites" {
  export default function deleteFavorites(param: {jobOfferId: any, userId: any}): Promise<any>;
}
declare module "@salesforce/apex/DT_FavoritesController.createFavorite" {
  export default function createFavorite(param: {jobOfferId: any, userId: any, contactId: any}): Promise<any>;
}
declare module "@salesforce/apex/DT_FavoritesController.getAllFavorites" {
  export default function getAllFavorites(): Promise<any>;
}
