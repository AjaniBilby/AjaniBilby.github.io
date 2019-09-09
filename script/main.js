window.addEventListener('load', ()=>{
	function UpdateScroll(){
		if (document.body.scrollTop / window.innerHeight > 0.1){
			document.body.setAttribute('scrolled', true);
		}else{
			document.body.removeAttribute('scrolled');
		}
	}

	document.body.onscroll = UpdateScroll;
	UpdateScroll();
});