
/*
**
** roberto-xz, 30-Maio 2025
**
*/

const analize = async () => {
	const detls = document.querySelectorAll('.x1uw6ca5');
	const posts = document.querySelectorAll('._aagw');
	
	let page_name = document.querySelectorAll('.x7a106z')[0].innerText.split('\n')[0]
	let all_posts = detls[0].innerText;
	let followers = detls[1].innerText;
	let following = detls[2].innerText;
	
	console.log('-----Analizando: [posts:'+posts.length+' encontrados]: aguarde isso pode demorar')
	const posts_analizeds = await __analize(posts)

	document.querySelectorAll('.x11njtxf')[3].click() // vai para a página de reels	
	console.log('-----Analizando: [reels:'+posts.length+' encontrados]: aguarde isso pode demorar')
	await sleep(1000) // almente caso sua internet seja lenta
	const reels = document.querySelectorAll('._aajy');
	const reals_analizeds = await __analize(reels)
	
	await sleep(1000) // almente caso sua internet seja lenta

	document.querySelectorAll('.x11njtxf')[4].click() // vai para a página tagged
	console.log('-----Analizando: [tagged:'+posts.length+' encontrados]: aguarde isso pode demorar')
	await sleep(1000) // almente caso sua internet seja lenta
	const tagged = document.querySelectorAll('._aagw');
	const tagged_analizeds = await __analize(tagged)

	return {
		page_name,all_posts,
		followers,following,
		posts_analizeds, reals_analizeds,
		tagged_analizeds
	}
}

const __analize = async (posts)=> {
	const post_list = []
	for (const post of posts ) {
		await sleep(2000) // espera 2 segudos antes de clicar no post
		post.click()      
		await sleep(2000) // espera 2 segundos para os elementos serem renderizados na arvore DOM
		let likes = document.querySelectorAll('.x12nagc')[0].innerText // qtd de likes do post
		let published_date = document.querySelectorAll('.x1p4m5qa')[0].innerText // data de publicação
		let comments = document.querySelectorAll('._a9zj').length
		let isVideo = document.querySelectorAll('._aatk')[0]?.querySelector('video') !== null;
		let isImage = document.querySelectorAll('._aatk')[0]?.querySelector('img') !== null;
		document.querySelectorAll('.xurb0ha')[2].click() // fecha o post
		await sleep(500) // espera meio segundo
		
		post_list.push({ 
			likes,isImage,isVideo,
			published_date, 
			comments
		});
	}

	return post_list
}

const sleep = (time) => new Promise(resolve => setTimeout(resolve, time));
//função para iniciar : analize().then(d => console.log(d))
