#!/usr/bin/env lua5.4

--[[
 **
 ** roberto-xz, 31 - Maio 2025
 **
--]]

local cjson = require "cjson"
local json_file = io.open("scraper_results.json", "r")
local json_data = json_file:read('*a')

local all_likes = 0
local all_posts = {total = 0, reels = 0, posts=0, taggd = 0}
local followers = 0
local following = 0
local averagelk = 0

local maximum_likes_in_one_post = {like=0, date = '', typer ='Video'}
local minimum_likes_in_one_post = {like=0, date = '', typer ='Video'}
local top_9_posts = {likes=0, date = '', typer =''}


-- função que retorna o média de likes por posts
local averg_likes = function()
     return all_likes/all_posts.total
end

-- função que gera um relatório com o número máximo de likes
local count_likes = function(json_data)
    local data = cjson.decode(json_data)
    local posts = data.posts_analizeds
    local reels = data.reals_analizeds

    for _, value in pairs(posts) do all_likes = all_likes + tonumber(value.likes:match("%d+")) end
    for _, value in pairs(reels) do all_likes = all_likes + tonumber(value.likes:match("%d+")) end
    return
end

-- gera um relatório com a quantidade de de pots publicados
local count_posts = function(json_data)
    local data = cjson.decode(json_data)
    local posts = data.posts_analizeds
    local reels = data.reals_analizeds
    local taggd = data.tagged_analizeds

    all_posts.total = (#reels+#posts)
    all_posts.posts = #posts
    all_posts.reels = #reels
    all_posts.taggd = #taggd
    return
end

-- gera um relatório do post com menos curtidas
local minimum_likes = function(json_data)
    local data = cjson.decode(json_data)
    local minimum = 9000

    local posts = data.posts_analizeds
    local reels = data.reals_analizeds
    local tabs = {posts, reels}

    for _, tab in pairs(tabs) do
        for _, value in pairs(tab) do
            local mx_like = tonumber(value.likes:match("%d+"))
            if mx_like <= minimum then
                minimum_likes_in_one_post.like = value.likes
                minimum_likes_in_one_post.date = value.published_date
                if value.isImage == true then minimum_likes_in_one_post.typer = 'Image' end
                minimum = mx_like
            end
        end
    end
end

-- gera um relatório do post com mais curtidas
local maximum_likes = function(json_data)
    local data = cjson.decode(json_data)
    local maximum = 0

    local posts = data.posts_analizeds
    local reels = data.reals_analizeds
    local tabs = {posts, reels}
    for _, tab in pairs(tabs) do
        for _, value in pairs(tab) do
            local mx_like = tonumber(value.likes:match("%d+"))
            if mx_like >= maximum then
                maximum_likes_in_one_post.like = value.likes
                maximum_likes_in_one_post.date = value.published_date
                if value.isImage == true then maximum_likes_in_one_post.typer = 'Image' end
            end
        end
    end
end

-- retorna quantos likes estão entre min, max likes
local count_between_likes_percent = function(json_data, min, max)
    local data = cjson.decode(json_data)
    local counts = 0;

    local posts = data.posts_analizeds
    local reels = data.reals_analizeds
    local tabs = {posts, reels}

    for _, tab in pairs(tabs) do
        for _, value in pairs(tab) do
            local likes = tonumber(value.likes:match("%d+"))
            if likes >= min and likes <= max then counts = counts+1 end
        end
    end
    return (counts/all_posts.total) * 100
end

-- order os 10 posts com mais curtidas
local order_top_10 = function(json_data)
    local top_10 = {}

    local data = cjson.decode(json_data)
    local posts = data.posts_analizeds
    local reels = data.reals_analizeds
    local tabs = {posts, reels}

    for _, tab in pairs(tabs) do
        for _, value in pairs(tab) do
            local _typer = 'Video'
            if (value.isImage == true) then _typer ='Image' end

            local post = {
                date=value.published_date,
                typer=_typer,
                likes= tonumber(value.likes:match("%d+"))
            }
            table.insert(top_10,post)
        end
    end
    table.sort(top_10, function(a, b) return a.likes > b.likes end)
    local result = {}

    for i = 1, math.min(10, #top_10) do
        table.insert(result, top_10[i])
    end
    return result
end

local calc_percent_like_by_type = function(json_data)
    local data = cjson.decode(json_data)
    local posts = data.posts_analizeds
    local reels = data.reals_analizeds
    local tabs = {posts, reels}

    local images = 0
    local videos = 0
    local images_and_video = 0

    for _, tab in pairs(tabs) do
        for _, value in pairs(tab) do
            if (value.isImage == true and  value.isVideo == false) then images = images + tonumber(value.likes:match("%d+")) end
            if (value.isImage == false and  value.isVideo == true) then videos = videos + tonumber(value.likes:match("%d+")) end
            if (value.isImage == true and  value.isVideo == true) then
                images_and_video = images_and_video + tonumber(value.likes:match("%d+"))
            end
        end
    end
    local result = 'images: '..images..' video: '..videos..' V&I: '..images_and_video
    return result
end


local main = function()
    count_likes(json_data)
    count_posts(json_data)
    maximum_likes(json_data)
    minimum_likes(json_data)

    print('total de postagems: '..all_posts.total)
    print('likes: '..all_likes)
    print('media de curtidas'..averg_likes())
    print('post com maior engajamento '..maximum_likes_in_one_post.like)
    print('post com menor engajamento '..minimum_likes_in_one_post.like)
    print('entre: 0-10 likes:',count_between_likes_percent(json_data,0,10))
    print('entre: 11-20 likes:',count_between_likes_percent(json_data,11,20))
    print('entre: 21-50 likes:',count_between_likes_percent(json_data,21,50))
    print('entre: 51+ likes:',count_between_likes_percent(json_data,51,5000))
    print('top 10 posts mais relevantes')
    for _,v in pairs(order_top_10(json_data)) do
        print('\tdata: '..v.date..' like: '..v.likes)
    end
    print('qual tipo gera mais engajamento (likes)')
    print(calc_percent_like_by_type(json_data))
end

main()
