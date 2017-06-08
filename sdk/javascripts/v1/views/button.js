'use strict';

// requires
//const fetch = require('fetch-ie8');
require('fetch-ie8');
//const Resource = require('resources');
//Resource().then(...).then(...)
const donor = {
	name:"Collaborator",
	surname:"Doe",
	roles:["donor"],
	api_key:"LF8TunqySaJuoRFLHpmJBkO4McCL3zhNY3HPtoxPYiS5ZVaI2oz1I5DIJ6TBPJ9LTOI3aCVNWhalluHF6VxJnG2U2F4KMsLGeJwVyPLzpLnJKddTjuFIaWU0iWHLtamB",
	user_id:91,
	id:"8114F38D-1F49-A962-00B3-C288EA9B66D8",
	current:"donor"
};
const journalist = {
	name:"Journalist",
	surname:"Doe",
	roles:["journalist"],
	user_id:90,
	id:"8114F38D-1F49-A962-00B3-C288EA9B66D8",
	current:"journalist"
};

const Promise = require('promise-polyfill');
const ViewBase = require('lib/view.js');


/**
*	Button component class
*	author: @dvinciguerra
*/
module.exports = class ButtonView extends ViewBase {

	// constructor (...and starting attributes)
	constructor(args = {}) {
		super(args);
		this._getDataAttributes();
	}


	isRendered() {
		return this._rendered;
	}

	// DOC: https://github.com/eokoe/libre-api/blob/master/t/donor/004-support.t#L21
	onSupportSubmit(event) {
		event.preventDefault();

		if(confirm('Você confirma a contribuição de 1 Libre por este conteúdo?')){
			// DEBUG: console.log(`//hapilibre.eokoe.com/api/journalist/${journalist.user_id}/support?api_key=${donor.api_key}`);
			fetch(`//hapilibre.eokoe.com/api/journalist/${journalist.user_id}/support?api_key=${donor.api_key}`, {
				method: 'POST'
			}).then((res) => {
				// success
				if (res.status >= 300) return res;
				console.log(res.json())

			}).then((res) => {
				if (res.status >= 400 && res.status < 500){}
				console.log(res.json())

			}).catch(function(error){
				console.error(`Button#supportSubmit event: ${error}`)

			})
		}
	}


	// bind events
	bind() {
		this.el().querySelectorAll('.lbr-sdk-button').forEach((x) => {
			x.addEventListener('submit', this.onSupportSubmit, false);
		});
	}


	// render component
	render(){
		if(!this.isRendered()) {
			let tmpl = this.template({config: this.config()});
			this.el().innerHTML = tmpl;
			this.bind();
			this._rendered = true;
		}
		return this.el()
	}

	// component template
	template(stash = {}){
		// TODO: maybe use a templete engine here in fucture
		// TODO: maybe in fucture: <iframe src="//midialibre.com.br/sdk/libre/button"
		//   frameborder="0" vertical-align: bottom; width: 150px; height: 24px;>
		// </iframe>
		return `
			<form class="lbr-sdk-button" href="#" style="">
				<input type="image" src="${stash.config.base + stash.config.assets.button}"
					height="30px" title="Gostou? Valorize, dê um Libre" />
			</form>
		`
	}

	// getting data-* attrs from element
	_getDataAttributes(){
		this._data = {};

		let el = this._el !== null || this._el !== undefined ? this._el : null;
		try {
			for(let i = 0; i < el.attributes.length; i++) {
				if(el.attributes[i].name && el.attributes[i].name.match(/^data-/)) {
					let k = el.attributes[i].name.replace(/^data-/, '');
					this._data[k] = el.attributes[i].value;
				}
			}
		}
		catch(e) {
			throw new Error(`Button#_getDataAttributes error: ${e.message}`);
		}

		return this._data
	}
}

