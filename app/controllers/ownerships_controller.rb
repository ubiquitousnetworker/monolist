class OwnershipsController < ApplicationController
  before_action :logged_in_user
  
  def create
    if params[:item_code]
      @item = Item.find_or_initialize_by(item_code: params[:item_code])
    else
      @item = Item.find(params[:item_id])
    end

    # itemsテーブルに存在しない場合は楽天のデータを登録する。
    if @item.new_record?
      items = RakutenWebService::Ichiba::Item.search(
        itemCode: @item.item_code
      )
      
      item                  = items.first
      @item.title           = item['itemName']
      @item.small_image     = item['smallImageUrls'].first['imageUrl']
      @item.medium_image    = item['mediumImageUrls'].first['imageUrl']
      @item.large_image     = item['mediumImageUrls'].first['imageUrl'].gsub('?_ex=128x128', '')
      @item.detail_page_url = item['itemUrl']
      @item.save!
    end
    
    # ユーザにwant or haveを設定する
    # params[:type]の値にHaveボタンが押された時には「Have」,
    # Wantボタンが押された時には「Want」が設定されています。
    current_user.want(@item) if params[:type] == "Want"
    current_user.have(@item) if params[:type] == "Have"
  end
  
  def destroy
    @item = Item.find(params[:item_id])
    
    # 紐付けの解除。 
    # params[:type]の値にHave itボタンが押された時には「Have」,
    # Want itボタンが押された時には「Want」が設定されています。
    #if params[:item_id] == "Have"
    #  item.unhave(@item)
    #else
    #  item.unwant(@item)
    #end
    current_user.unwant(@item) if params[:type] == "Want"
    current_user.unhave(@item) if params[:type] == "Have"
  end

end
