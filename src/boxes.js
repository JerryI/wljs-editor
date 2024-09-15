
  let boxes = {};
  boxes.name = "WebObjects/Boxes";

  interpretate.contextExpand(boxes);

  boxes.NumberMarks = () => "NumberMarks"
  boxes.ShowStringCharacters = () => "ShowStringCharacters"

  boxes.Background = () => "Background"

  boxes.RotationBox = async (args, env) => {
    const degrees = await interpretate(args[0], env);
    env.element.style.transform = `rotate(${Math.floor(degrees/Math.PI*180.0)}deg)`
  }

  boxes.RowBox = async (args, env) => {
    console.log(args);
  }

  boxes.PaneBox = async (args, env) => {
    env.element.classList.add(...('sm-controls cursor-default rounded-md 0 py-1 px-2 bg-gray-100 text-left text-gray-500 ring-1 ring-inset ring-gray-400 text-xs flex flex-row'.split(' '))); 
  
    const opts = await core._getRules(args, {...env, hold:true});
    if (opts.ImageSize) {
      const size = await interpretate(opts.ImageSize, env);
      if (size instanceof Object === true) {
        env.element.style.width = size[0] + 'px';
        env.element.style.height = size[1] + 'px';
      } else {
        env.element.style.maxWidth = size + 'px';
      }
    }

    if (opts.Event) {
      const ev = await interpretate(opts.Event, env);
      env.element.addEventListener('click', () => {
        console.log('clicked!');
        server.kernel.emitt(ev, 'True', 'Click')
      })
    }
  }

  boxes.RootBox = async (args, env) => {
    const approx = await interpretate(args[0], env);

    env.element.classList.add(...('sm-controls cursor-default rounded-md 0 py-1 px-2 bg-gray-100 text-left text-gray-500 ring-1 ring-inset ring-gray-400 text-xs flex flex-row items-center'.split(' '))); 
    
    
    const logo = document.createElement('span');
    logo.innerHTML = `<svg class="w-5 h-5 text-teal-500" viewBox="0 0 512 512" >
<g fill="currentColor">
	<g>
		<path d="M491.841,156.427c-19.471-45.946-51.936-85.013-92.786-112.637C358.217,16.166,308.893-0.007,256,0
			c-35.254-0.002-68.946,7.18-99.571,20.158C110.484,39.63,71.416,72.093,43.791,112.943C16.167,153.779-0.007,203.104,0,256
			c-0.002,35.255,7.181,68.948,20.159,99.573c19.471,45.946,51.937,85.013,92.786,112.637C153.783,495.834,203.107,512.007,256,512
			c35.253,0.002,68.946-7.18,99.571-20.158c45.945-19.471,85.013-51.935,112.638-92.785C495.834,358.22,512.007,308.894,512,256
			C512.002,220.744,504.819,187.052,491.841,156.427z M460.413,342.257c-16.851,39.781-45.045,73.724-80.476,97.677
			c-35.443,23.953-78.02,37.926-123.936,37.933c-30.619-0.002-59.729-6.218-86.255-17.454
			c-39.781-16.85-73.724-45.044-97.677-80.475C48.114,344.495,34.14,301.917,34.133,256c0.002-30.62,6.219-59.731,17.454-86.257
			c16.851-39.781,45.045-73.724,80.476-97.677C167.506,48.112,210.084,34.139,256,34.132c30.619,0.002,59.729,6.218,86.255,17.454
			c39.781,16.85,73.724,45.044,97.677,80.475c23.953,35.443,37.927,78.02,37.934,123.938
			C477.864,286.62,471.648,315.731,460.413,342.257z"/>
	</g>
</g>
<g fill="currentColor">
	<g>
		<path d="M389.594,128.108v-0.136h-77.93c-6.234,0-11.905,3.64-14.693,9.217L189.203,352.792l-52.104-104.309
			c-2.789-5.576-8.459-9.182-14.693-9.182H89.007c-9.073,0-16.428,7.626-16.428,16.699c0,9.072,7.355,16.699,16.428,16.699h23.245
			l62.256,124.377c2.789,5.576,8.459,9.013,14.693,9.013c6.234,0,11.905-3.402,14.693-8.979l117.923-235.74h67.777
			c9.072,0,16.428-7.558,16.428-16.631C406.022,135.667,398.668,128.108,389.594,128.108z"/>
	</g>
</g>
</svg>`;
    const a = document.createElement('span');
    if (Complex.isComplex(approx)) {
      a.innerText = `${approx.re} + i ${approx.im}`;
    } else {
      a.innerText = approx;
    }
    a.classList.add('px-1');
    env.element.appendChild(logo);
    env.element.appendChild(a);


  }
  boxes.TransposeBox = async (args, env) => {
    const post = document.createElement('sup');
  
    post.innerHTML = await interpretate(args[0], env)
    
  
    const editor = document.createElement('span');
    env.global.element = editor;
  
    env.element.style.display = "inline-flex";
    env.element.style.alignItems = "baseline";
  
    env.element.appendChild(editor);
    env.element.appendChild(post); 
  }

  boxes.DerivativeBox = async (args, env) => {
    const post = document.createElement('sup');
    const powers = await interpretate(args[0], env);
  
    post.innerHTML = "("+powers.join(',')+")";
  
    const editor = document.createElement('span');
    env.global.element = editor;
  
    env.element.style.display = "inline-flex";
    env.element.style.alignItems = "baseline";
  
    env.element.appendChild(editor);
    env.element.appendChild(post);    
  }

  boxes.PiecewiseBox = async (args, env) => {
    //let vars = await interpretate(args[0], env);
    const taken = env.children;
    const bonds = [];
    for (let i=0; i<taken.length; i = i + 2) {
      bonds.push([taken[i], taken[i+1]]);
    }       

    const outerDiv = document.createElement('table');
    outerDiv.style.paddingLeft = "0.5rem";
    outerDiv.style.borderLeft = "1px solid black";
    outerDiv.style.borderBottomLeftRadius ="10px";
    outerDiv.style.borderTopLeftRadius = "10px";
    env.element.appendChild(outerDiv);
    outerDiv.classList.add('flex', 'flex-row', 'items-center');

    const table = document.createElement('tbody');
    //table.classList.add('flex', 'flex-col');
    bonds.forEach((pair) => {
      const p = document.createElement('tr');
      //p.classList.add('flex', 'flex-row');
      const cell1 = document.createElement('td');
      cell1.appendChild(pair[0]);
      const cell2 = document.createElement('td');
      cell2.classList.add('pl-5');
      cell2.appendChild(pair[1]);
      p.appendChild(cell1);
      p.appendChild(cell2);

      table.appendChild(p);
    });

    outerDiv.appendChild(table);


  }

  boxes.SumBox = async (args, env) => {
    let vars = await interpretate(args[0], env);
    let bonds = await interpretate(args[1], env);
    
    const number = vars;
    const taken = env.children.slice(1);
    vars = [];
    bonds = [];
    for (let i=0; i<taken.length; i = i + 3) {
      vars.push(taken[i]);
      bonds.push([taken[i+1], taken[i+2]]);
    }   

    const outerDiv = document.createElement('div');
    env.element.appendChild(outerDiv);
    outerDiv.classList.add('flex', 'flex-row', 'items-center');
    // Create the SVG container div
    for (let i=0; i<vars.length; ++i) {
      const svgContainer = document.createElement('div');
      svgContainer.innerHTML = `<svg class="w-7 h-13 text-gray-800" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path d="M18.809 22H3.46l8.386-10.483L3.386 2H19v3h-1V3H5.613l7.541 8.483L5.54 21h12.65l.92-1.838.894.447z"/><path fill="none" d="M0 0h24v24H0z"/></svg>`;
    
      // Append the SVG container to the outer div
      //outerDiv.appendChild(svgContainer);
      if (bonds) {
        if (i == vars.length - 1) continue;
        const flexColDiv = document.createElement('div');
        flexColDiv.classList.add('flex', 'flex-col', 'h-full', 'justify-between', 'mr-1');
        bonds[i][1].classList.add('text-xs');
        flexColDiv.appendChild(bonds[i][1]);

        const wrapper = document.createElement('span');
        wrapper.classList.add('text-xs', 'flex', 'flex-row');
        wrapper.appendChild(vars[i]);
        wrapper.appendChild(document.createTextNode('='));
        wrapper.appendChild(bonds[i][0]);
        flexColDiv.appendChild(svgContainer);
        flexColDiv.appendChild(wrapper); 
        outerDiv.appendChild(flexColDiv);       
      }
    }
    // Create the flex-col div
    const flexColDiv = document.createElement('div');
    flexColDiv.classList.add('flex', 'flex-col');
    // Create the first text div

    // Create the middle div containing spans
    const middleDiv = document.createElement('div');
    middleDiv.classList.add('flex', 'flex-row');

    if (bonds) {
      const lastBound = bonds[bonds.length - 1];
      lastBound[0].classList.add('text-xs');
      lastBound[1].classList.add('text-xs');
      


      lastBound[1].classList.add('text-xs');
      flexColDiv.appendChild(lastBound[1]);

      const svgContainer = document.createElement('div');
      svgContainer.innerHTML = `<svg class="w-7 h-13 text-gray-800" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path d="M18.809 22H3.46l8.386-10.483L3.386 2H19v3h-1V3H5.613l7.541 8.483L5.54 21h12.65l.92-1.838.894.447z"/><path fill="none" d="M0 0h24v24H0z"/></svg>`;
    

      const wrapper = document.createElement('span');
      wrapper.classList.add('text-xs', 'flex', 'flex-row');
      wrapper.appendChild(vars[bonds.length - 1]);
      wrapper.appendChild(document.createTextNode('='));
      wrapper.appendChild(lastBound[0]);
      flexColDiv.appendChild(svgContainer);
      flexColDiv.appendChild(wrapper); 

    } else {
      flexColDiv.appendChild(middleDiv);
    }

    outerDiv.appendChild(flexColDiv);

    outerDiv.appendChild(env.children[0]);
    // Create the second text div
    // Append the text and middle divs to the flex-col div
    return;
  }

  boxes.IntegrateBox = async (args, env) => {
    //const options = await core._getRules(args, env);

    let vars = await interpretate(args[0], env);
    let bonds = await interpretate(args[1], env);

    const number = vars;
    if (bonds) {
      const taken = env.children.slice(1);
      vars = [];
      bonds = [];
      for (let i=0; i<taken.length; i = i + 3) {
        vars.push(taken[i]);
        bonds.push([taken[i+1], taken[i+2]]);
      }
    } else {
      vars = env.children.slice(1, number + 1); 
    }

   

    const outerDiv = document.createElement('div');
    env.element.appendChild(outerDiv);
    outerDiv.classList.add('flex', 'flex-row', 'items-center');
    // Create the SVG container div
    for (let i=0; i<vars.length; ++i) {
      const svgContainer = document.createElement('div');
      svgContainer.innerHTML = `<svg class="w-4 h-10 text-gray-800" viewBox="28 7 2.000000 55.000000" preserveAspectRatio="xMidYMid meet">

<g transform="translate(0.000000,75.000000) scale(0.100000,-0.100000)" fill="#000000" stroke="none">
<path d="M342 648 c-24 -29 -49 -130 -87 -343 -19 -107 -33 -155 -46 -155 -5 0 -8 3 -7 7 2 5 0 9 -4 11 -5 1 -8 0 -8 -3 0 -3 0 -9 0 -15 0 -5 9 -10 20 -10 32 0 48 47 90 262 40 203 59 271 67 236 6 -23 26 -23 21 -1 -4 22 -31 28 -46 11z"></path>
</g>
</svg>`;
    
      // Append the SVG container to the outer div
      outerDiv.appendChild(svgContainer);
      if (bonds) {
        if (i == vars.length - 1) continue;
        const flexColDiv = document.createElement('div');
        flexColDiv.classList.add('flex', 'flex-col', 'h-full', 'justify-between', 'mr-1');
        bonds[i][0].classList.add('text-xs', '-ml-2');

        bonds[i][1].classList.add('text-xs');
        flexColDiv.appendChild(bonds[i][1]);
        flexColDiv.appendChild(bonds[i][0]); 
        outerDiv.appendChild(flexColDiv);       
      }
    }
    // Create the flex-col div
    const flexColDiv = document.createElement('div');
    flexColDiv.classList.add('flex', 'flex-col');
    // Create the first text div

    // Create the middle div containing spans
    const middleDiv = document.createElement('div');
    middleDiv.classList.add('flex', 'flex-row');

    if (bonds) {
      const lastBound = bonds[bonds.length - 1];
      lastBound[0].classList.add('text-xs', '-ml-2');
      lastBound[1].classList.add('text-xs');
      
      flexColDiv.appendChild(lastBound[1]);
      flexColDiv.appendChild(middleDiv);
      flexColDiv.appendChild(lastBound[0]);
    } else {
      flexColDiv.appendChild(middleDiv);
    }

    outerDiv.appendChild(flexColDiv);

    middleDiv.appendChild(env.children[0]);

    for (let i=0; i<vars.length; ++i) {
      const sign = document.createElement('span');
      sign.innerHTML = "&dd;";
      sign.classList.add('ml-1');
      middleDiv.appendChild(sign);
      middleDiv.appendChild(vars[i]);
    }
    // Create the second text div
    // Append the text and middle divs to the flex-col div
    return;

  }

  boxes["ViewBox`InnerExpression"] = async (args, env) => {
    if (args.length == 0) {
      //console.log(env.global.EditorWidget.getDoc());
      return env.global.EditorWidget.getDoc();
    } 

    const changes = await interpretate(args[0], env);
    env.global.EditorWidget.applyChanges(changes);
    return changes;
  }

  boxes["ViewBox`OuterExpression"] = async (args, env) => {
    const changes = await interpretate(args[0], env);
    env.global.EditorWidget.applyOuterChanges(changes);
  }  

  boxes.FrameBox = async (args, env) => {
      env.element.classList.add('frame-box');
      env.context = boxes;

      const options = await core._getRules(args, env) || {};
      
      if ('Background' in options) {
          env.element.style.backgroundColor = options.Background;
      }
  }

  boxes.IconizeFileBox = async (args, env) => {
    env.context = boxes;
    env.element.classList.add(...('sm-controls cursor-default rounded-md 0 py-1 px-2 bg-gray-100 text-left text-gray-500 ring-1 ring-inset ring-gray-400 text-xs'.split(' ')));
    const count = await interpretate(args[0], env);
    const opts = await core._getRules(args, env);
    if (opts.Label && opts.Label != 'None') {
      env.element.innerHTML = `
      <svg class="w-4 h-4 text-gray-500 inline-block mt-auto mb-auto" viewBox="0 0 24 24" fill="none"><path d="M12.6385 3.05526L12.8719 2.08289L12.6385 3.05526ZM13.9373 3.93726L13.2302 4.64437L13.9373 3.93726ZM13.2166 3.29472L13.7391 2.44208L13.2166 3.29472ZM6.09202 20.782L6.54601 19.891L6.09202 20.782ZM5.21799 19.908L6.10899 19.454L5.21799 19.908ZM17.908 20.782L17.454 19.891L17.908 20.782ZM18.782 19.908L17.891 19.454L18.782 19.908ZM18.0627 8.06274L18.7698 7.35563L18.0627 8.06274ZM18.7053 8.78343L19.5579 8.26093L18.7053 8.78343ZM18.9447 9.36154L19.9171 9.12809L18.9447 9.36154ZM5.21799 4.09202L6.10899 4.54601L5.21799 4.09202ZM6.09202 3.21799L6.54601 4.10899L6.09202 3.21799ZM13.9701 11.7575C13.8362 11.2217 13.2933 10.8959 12.7575 11.0299C12.2217 11.1638 11.8959 11.7067 12.0299 12.2425L13.9701 11.7575ZM14.5 18L13.5299 18.2425C13.6411 18.6877 14.0411 19 14.5 19C14.9589 19 15.3589 18.6877 15.4701 18.2425L14.5 18ZM16.9701 12.2425C17.1041 11.7067 16.7783 11.1638 16.2425 11.0299C15.7067 10.8959 15.1638 11.2217 15.0299 11.7575L16.9701 12.2425ZM11 19C11.5523 19 12 18.5523 12 18C12 17.4477 11.5523 17 11 17V19ZM9.23463 17.8478L8.85195 18.7716H8.85195L9.23463 17.8478ZM8.15224 16.7654L7.22836 17.1481H7.22836L8.15224 16.7654ZM11 13C11.5523 13 12 12.5523 12 12C12 11.4477 11.5523 11 11 11V13ZM9.23463 12.1522L8.85195 11.2284L9.23463 12.1522ZM8.15224 13.2346L7.22836 12.8519L8.15224 13.2346ZM14 3.17981C14 2.62752 13.5523 2.17981 13 2.17981C12.4477 2.17981 12 2.62752 12 3.17981H14ZM18.82 10C19.3723 10 19.82 9.55229 19.82 9C19.82 8.44772 19.3723 8 18.82 8V10ZM15.8 20H8.2V22H15.8V20ZM6 17.8V6.2H4V17.8H6ZM8.2 4H11.6745V2H8.2V4ZM18 10.3255V17.8H20V10.3255H18ZM11.6745 4C12.2113 4 12.3167 4.00643 12.405 4.02763L12.8719 2.08289C12.4999 1.99357 12.1161 2 11.6745 2V4ZM14.6444 3.23015C14.3321 2.91791 14.0653 2.64199 13.7391 2.44208L12.6941 4.14736C12.7715 4.19482 12.8506 4.2648 13.2302 4.64437L14.6444 3.23015ZM12.405 4.02763C12.5071 4.05213 12.6046 4.09253 12.6941 4.14736L13.7391 2.44208C13.4707 2.27759 13.178 2.15638 12.8719 2.08289L12.405 4.02763ZM8.2 20C7.62345 20 7.25117 19.9992 6.96784 19.9761C6.69617 19.9539 6.59545 19.9162 6.54601 19.891L5.63803 21.673C6.01641 21.8658 6.40963 21.9371 6.80497 21.9694C7.18864 22.0008 7.65645 22 8.2 22V20ZM4 17.8C4 18.3436 3.99922 18.8114 4.03057 19.195C4.06287 19.5904 4.13419 19.9836 4.32698 20.362L6.10899 19.454C6.0838 19.4045 6.04612 19.3038 6.02393 19.0322C6.00078 18.7488 6 18.3766 6 17.8H4ZM6.54601 19.891C6.35785 19.7951 6.20487 19.6422 6.10899 19.454L4.32698 20.362C4.6146 20.9265 5.07354 21.3854 5.63803 21.673L6.54601 19.891ZM15.8 22C16.3436 22 16.8114 22.0008 17.195 21.9694C17.5904 21.9371 17.9836 21.8658 18.362 21.673L17.454 19.891C17.4045 19.9162 17.3038 19.9539 17.0322 19.9761C16.7488 19.9992 16.3766 20 15.8 20V22ZM18 17.8C18 18.3766 17.9992 18.7488 17.9761 19.0322C17.9539 19.3038 17.9162 19.4045 17.891 19.454L19.673 20.362C19.8658 19.9836 19.9371 19.5904 19.9694 19.195C20.0008 18.8114 20 18.3436 20 17.8H18ZM18.362 21.673C18.9265 21.3854 19.3854 20.9265 19.673 20.362L17.891 19.454C17.7951 19.6422 17.6422 19.7951 17.454 19.891L18.362 21.673ZM17.3556 8.76985C17.7352 9.14941 17.8052 9.22849 17.8526 9.30593L19.5579 8.26093C19.358 7.93471 19.0821 7.66788 18.7698 7.35563L17.3556 8.76985ZM20 10.3255C20 9.8839 20.0064 9.50012 19.9171 9.12809L17.9724 9.59498C17.9936 9.6833 18 9.7887 18 10.3255H20ZM17.8526 9.30593C17.9075 9.3954 17.9479 9.49295 17.9724 9.59498L19.9171 9.12809C19.8436 8.82198 19.7224 8.52935 19.5579 8.26093L17.8526 9.30593ZM6 6.2C6 5.62345 6.00078 5.25117 6.02393 4.96784C6.04612 4.69617 6.0838 4.59545 6.10899 4.54601L4.32698 3.63803C4.13419 4.01641 4.06287 4.40963 4.03057 4.80497C3.99922 5.18864 4 5.65645 4 6.2H6ZM8.2 2C7.65645 2 7.18864 1.99922 6.80497 2.03057C6.40963 2.06287 6.01641 2.13419 5.63803 2.32698L6.54601 4.10899C6.59545 4.0838 6.69617 4.04612 6.96784 4.02393C7.25117 4.00078 7.62345 4 8.2 4V2ZM6.10899 4.54601C6.20487 4.35785 6.35785 4.20487 6.54601 4.10899L5.63803 2.32698C5.07354 2.6146 4.6146 3.07354 4.32698 3.63803L6.10899 4.54601ZM12.0299 12.2425L13.5299 18.2425L15.4701 17.7575L13.9701 11.7575L12.0299 12.2425ZM15.4701 18.2425L16.9701 12.2425L15.0299 11.7575L13.5299 17.7575L15.4701 18.2425ZM11 17C10.5204 17 10.2107 16.9995 9.97376 16.9833C9.74576 16.9677 9.65893 16.9411 9.61732 16.9239L8.85195 18.7716C9.17788 18.9066 9.50779 18.9561 9.83762 18.9787C10.1585 19.0005 10.5477 19 11 19V17ZM7 15C7 15.4523 6.99946 15.8415 7.02135 16.1624C7.04385 16.4922 7.09336 16.8221 7.22836 17.1481L9.07612 16.3827C9.05888 16.3411 9.03227 16.2542 9.01671 16.0262C9.00054 15.7893 9 15.4796 9 15H7ZM9.61732 16.9239C9.37229 16.8224 9.17761 16.6277 9.07612 16.3827L7.22836 17.1481C7.53284 17.8831 8.11687 18.4672 8.85195 18.7716L9.61732 16.9239ZM11 11C10.5477 11 10.1585 10.9995 9.83762 11.0213C9.50779 11.0439 9.17788 11.0934 8.85195 11.2284L9.61732 13.0761C9.65893 13.0589 9.74576 13.0323 9.97376 13.0167C10.2107 13.0005 10.5204 13 11 13V11ZM9 15C9 14.5204 9.00054 14.2107 9.01671 13.9738C9.03227 13.7458 9.05888 13.6589 9.07612 13.6173L7.22836 12.8519C7.09336 13.1779 7.04385 13.5078 7.02135 13.8376C6.99946 14.1585 7 14.5477 7 15H9ZM8.85195 11.2284C8.11686 11.5328 7.53284 12.1169 7.22836 12.8519L9.07612 13.6173C9.17761 13.3723 9.37229 13.1776 9.61732 13.0761L8.85195 11.2284ZM12 3.17981V8H14V3.17981H12ZM14 10H18.82V8H14V10ZM12 8C12 9.10457 12.8954 10 14 10V8V8H12ZM13.2302 4.64437L17.3556 8.76985L18.7698 7.35563L14.6444 3.23015L13.2302 4.64437Z" fill="currentColor"></path> </svg> 
      <span class="leading-normal pl-1">${opts.Label}</span>`;
    } else {
      env.element.innerHTML = `
      <svg class="w-4 h-4 text-gray-500 inline-block mt-auto mb-auto" viewBox="0 0 24 24" fill="none"><path d="M12.6385 3.05526L12.8719 2.08289L12.6385 3.05526ZM13.9373 3.93726L13.2302 4.64437L13.9373 3.93726ZM13.2166 3.29472L13.7391 2.44208L13.2166 3.29472ZM6.09202 20.782L6.54601 19.891L6.09202 20.782ZM5.21799 19.908L6.10899 19.454L5.21799 19.908ZM17.908 20.782L17.454 19.891L17.908 20.782ZM18.782 19.908L17.891 19.454L18.782 19.908ZM18.0627 8.06274L18.7698 7.35563L18.0627 8.06274ZM18.7053 8.78343L19.5579 8.26093L18.7053 8.78343ZM18.9447 9.36154L19.9171 9.12809L18.9447 9.36154ZM5.21799 4.09202L6.10899 4.54601L5.21799 4.09202ZM6.09202 3.21799L6.54601 4.10899L6.09202 3.21799ZM13.9701 11.7575C13.8362 11.2217 13.2933 10.8959 12.7575 11.0299C12.2217 11.1638 11.8959 11.7067 12.0299 12.2425L13.9701 11.7575ZM14.5 18L13.5299 18.2425C13.6411 18.6877 14.0411 19 14.5 19C14.9589 19 15.3589 18.6877 15.4701 18.2425L14.5 18ZM16.9701 12.2425C17.1041 11.7067 16.7783 11.1638 16.2425 11.0299C15.7067 10.8959 15.1638 11.2217 15.0299 11.7575L16.9701 12.2425ZM11 19C11.5523 19 12 18.5523 12 18C12 17.4477 11.5523 17 11 17V19ZM9.23463 17.8478L8.85195 18.7716H8.85195L9.23463 17.8478ZM8.15224 16.7654L7.22836 17.1481H7.22836L8.15224 16.7654ZM11 13C11.5523 13 12 12.5523 12 12C12 11.4477 11.5523 11 11 11V13ZM9.23463 12.1522L8.85195 11.2284L9.23463 12.1522ZM8.15224 13.2346L7.22836 12.8519L8.15224 13.2346ZM14 3.17981C14 2.62752 13.5523 2.17981 13 2.17981C12.4477 2.17981 12 2.62752 12 3.17981H14ZM18.82 10C19.3723 10 19.82 9.55229 19.82 9C19.82 8.44772 19.3723 8 18.82 8V10ZM15.8 20H8.2V22H15.8V20ZM6 17.8V6.2H4V17.8H6ZM8.2 4H11.6745V2H8.2V4ZM18 10.3255V17.8H20V10.3255H18ZM11.6745 4C12.2113 4 12.3167 4.00643 12.405 4.02763L12.8719 2.08289C12.4999 1.99357 12.1161 2 11.6745 2V4ZM14.6444 3.23015C14.3321 2.91791 14.0653 2.64199 13.7391 2.44208L12.6941 4.14736C12.7715 4.19482 12.8506 4.2648 13.2302 4.64437L14.6444 3.23015ZM12.405 4.02763C12.5071 4.05213 12.6046 4.09253 12.6941 4.14736L13.7391 2.44208C13.4707 2.27759 13.178 2.15638 12.8719 2.08289L12.405 4.02763ZM8.2 20C7.62345 20 7.25117 19.9992 6.96784 19.9761C6.69617 19.9539 6.59545 19.9162 6.54601 19.891L5.63803 21.673C6.01641 21.8658 6.40963 21.9371 6.80497 21.9694C7.18864 22.0008 7.65645 22 8.2 22V20ZM4 17.8C4 18.3436 3.99922 18.8114 4.03057 19.195C4.06287 19.5904 4.13419 19.9836 4.32698 20.362L6.10899 19.454C6.0838 19.4045 6.04612 19.3038 6.02393 19.0322C6.00078 18.7488 6 18.3766 6 17.8H4ZM6.54601 19.891C6.35785 19.7951 6.20487 19.6422 6.10899 19.454L4.32698 20.362C4.6146 20.9265 5.07354 21.3854 5.63803 21.673L6.54601 19.891ZM15.8 22C16.3436 22 16.8114 22.0008 17.195 21.9694C17.5904 21.9371 17.9836 21.8658 18.362 21.673L17.454 19.891C17.4045 19.9162 17.3038 19.9539 17.0322 19.9761C16.7488 19.9992 16.3766 20 15.8 20V22ZM18 17.8C18 18.3766 17.9992 18.7488 17.9761 19.0322C17.9539 19.3038 17.9162 19.4045 17.891 19.454L19.673 20.362C19.8658 19.9836 19.9371 19.5904 19.9694 19.195C20.0008 18.8114 20 18.3436 20 17.8H18ZM18.362 21.673C18.9265 21.3854 19.3854 20.9265 19.673 20.362L17.891 19.454C17.7951 19.6422 17.6422 19.7951 17.454 19.891L18.362 21.673ZM17.3556 8.76985C17.7352 9.14941 17.8052 9.22849 17.8526 9.30593L19.5579 8.26093C19.358 7.93471 19.0821 7.66788 18.7698 7.35563L17.3556 8.76985ZM20 10.3255C20 9.8839 20.0064 9.50012 19.9171 9.12809L17.9724 9.59498C17.9936 9.6833 18 9.7887 18 10.3255H20ZM17.8526 9.30593C17.9075 9.3954 17.9479 9.49295 17.9724 9.59498L19.9171 9.12809C19.8436 8.82198 19.7224 8.52935 19.5579 8.26093L17.8526 9.30593ZM6 6.2C6 5.62345 6.00078 5.25117 6.02393 4.96784C6.04612 4.69617 6.0838 4.59545 6.10899 4.54601L4.32698 3.63803C4.13419 4.01641 4.06287 4.40963 4.03057 4.80497C3.99922 5.18864 4 5.65645 4 6.2H6ZM8.2 2C7.65645 2 7.18864 1.99922 6.80497 2.03057C6.40963 2.06287 6.01641 2.13419 5.63803 2.32698L6.54601 4.10899C6.59545 4.0838 6.69617 4.04612 6.96784 4.02393C7.25117 4.00078 7.62345 4 8.2 4V2ZM6.10899 4.54601C6.20487 4.35785 6.35785 4.20487 6.54601 4.10899L5.63803 2.32698C5.07354 2.6146 4.6146 3.07354 4.32698 3.63803L6.10899 4.54601ZM12.0299 12.2425L13.5299 18.2425L15.4701 17.7575L13.9701 11.7575L12.0299 12.2425ZM15.4701 18.2425L16.9701 12.2425L15.0299 11.7575L13.5299 17.7575L15.4701 18.2425ZM11 17C10.5204 17 10.2107 16.9995 9.97376 16.9833C9.74576 16.9677 9.65893 16.9411 9.61732 16.9239L8.85195 18.7716C9.17788 18.9066 9.50779 18.9561 9.83762 18.9787C10.1585 19.0005 10.5477 19 11 19V17ZM7 15C7 15.4523 6.99946 15.8415 7.02135 16.1624C7.04385 16.4922 7.09336 16.8221 7.22836 17.1481L9.07612 16.3827C9.05888 16.3411 9.03227 16.2542 9.01671 16.0262C9.00054 15.7893 9 15.4796 9 15H7ZM9.61732 16.9239C9.37229 16.8224 9.17761 16.6277 9.07612 16.3827L7.22836 17.1481C7.53284 17.8831 8.11687 18.4672 8.85195 18.7716L9.61732 16.9239ZM11 11C10.5477 11 10.1585 10.9995 9.83762 11.0213C9.50779 11.0439 9.17788 11.0934 8.85195 11.2284L9.61732 13.0761C9.65893 13.0589 9.74576 13.0323 9.97376 13.0167C10.2107 13.0005 10.5204 13 11 13V11ZM9 15C9 14.5204 9.00054 14.2107 9.01671 13.9738C9.03227 13.7458 9.05888 13.6589 9.07612 13.6173L7.22836 12.8519C7.09336 13.1779 7.04385 13.5078 7.02135 13.8376C6.99946 14.1585 7 14.5477 7 15H9ZM8.85195 11.2284C8.11686 11.5328 7.53284 12.1169 7.22836 12.8519L9.07612 13.6173C9.17761 13.3723 9.37229 13.1776 9.61732 13.0761L8.85195 11.2284ZM12 3.17981V8H14V3.17981H12ZM14 10H18.82V8H14V10ZM12 8C12 9.10457 12.8954 10 14 10V8V8H12ZM13.2302 4.64437L17.3556 8.76985L18.7698 7.35563L14.6444 3.23015L13.2302 4.64437Z" fill="currentColor"></path> </svg> 
      <span class="leading-normal pl-1">${count} bytes</span>`;
    }

  }

  boxes.IconizeBox = async (args, env) => {
    env.context = boxes;
    env.element.classList.add(...('sm-controls cursor-default rounded-md 0 py-1 px-2 bg-gray-100 text-left text-gray-500 ring-1 ring-inset ring-gray-400 text-xs'.split(' ')));
    const count = await interpretate(args[0], env);
    const opts = await core._getRules(args, env);

    if (opts.Label && opts.Label != 'None') {
      env.element.innerHTML = `
      <svg class="w-4 h-4 text-gray-500 inline-block mt-auto mb-auto" viewBox="0 0 24 24" fill="none">
  <path d="M18 2L6 2" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M18 22L6 22" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M12 5V10M12 10L15 7M12 10L9 7" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M12 19V14M12 14L15 17M12 14L9 17" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  </svg> <span class="leading-normal pl-1">${opts.Label}</span>`;
    } else {
      env.element.innerHTML = `
      <svg class="w-4 h-4 text-gray-500 inline-block mt-auto mb-auto" viewBox="0 0 24 24" fill="none">
  <path d="M18 2L6 2" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M18 22L6 22" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M12 5V10M12 10L15 7M12 10L9 7" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M12 19V14M12 14L15 17M12 14L9 17" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
  </svg> <span class="leading-normal pl-1">${count} bytes</span>`;
    }

  }

  boxes.Italic = () => "Italic"
  boxes.Bold = () => "Bold"
  boxes.Underlined = () => "Underlined"
  boxes.FontSize = () => "FontSize"
  boxes.FontFamily = () => "FontFamily"

  boxes.StringBox = async (args, env) => {
    env.context = boxes;
    console.log('string style box');
    
    console.log(args);

    //sort all rules to the end
    args.sort((el) => {
      if(Array.isArray(el)) {
        if (el[0] == 'Rule') return 1;
      }
      return -1;
    });

    const options = await core._getRules(args, env) || {};

    env.element.style.fontFamily = 'system-ui';
    
    if ('Background' in options) {
      env.element.style.backgroundColor = options.Background;
    } 

    if ('FontSize' in options) {
      env.element.style.fontSize = String(options.FontSize) + 'pt';
    } 

    if ('FontFamily' in options) {
      env.element.style.fontFamily = options.FontFamily.toLowerCase();
    }
    
    const data = [];
    for (let i=0; i<(args.length - Object.keys(options).length); ++i) {
      let result = await interpretate(args[i], env);

      if (typeof result == 'string') {
        result = result.toLocaleLowerCase();
        
        if (result.slice(0,3) == 'rgb') {
          //this is a color
          env.element.style.color = result;
        } else {
          //this is a font-face
          if (result == 'italic') {
            env.element.style.fontStyle = result;
          } else if (result == 'bold') {
            env.element.style.fontWeight = result;
          } else {
            env.element.style.textDecoration = result;
          }
        }
        continue;
      }

      
      if (typeof result === 'number') {

        env.element.style.fontSize = String(result) + 'pt';
        continue;
      }
    }

    console.log(data);
  }

  boxes.CommentBox = async (args, env) => {
    env.context = boxes;
    const color = await interpretate(args[0], env);
    env.element.style.color = color;
    env.element.classList.add('subscript-tail', 'sm-controls', 'text-sm');
  }

  boxes.StyleBox = async (args, env) => {
      env.context = boxes;
      console.log('style box');
      
      //sort all rules to the end
      args.sort((el) => {
        if(Array.isArray(el)) {
          if (el[0] == 'Rule') return 1;
        }
        return -1;
      });

      const options = await core._getRules(args, env) || {};

      //env.element.style.fontFamily = 'system-ui';

      if ('Background' in options) {
        env.element.style.backgroundColor = options.Background;
      } 

      if ('FontSize' in options) {
        env.element.style.fontSize = String(options.FontSize) + 'pt';
      } 

      if ('FontFamily' in options) {
        env.element.style.fontFamily = options.FontFamily.toLowerCase();
      }

      const data = [];
      for (let i=0; i<(args.length - Object.keys(options).length); ++i) {
        let result = await interpretate(args[i], env);
      
        if (typeof result == 'string') {
          result = result.toLocaleLowerCase();

          if (result.slice(0,3) == 'rgb') {
            //this is a color
            env.element.style.color = result;
          } else {
            //this is a font-face
            if (result == 'italic') {
              env.element.style.fontStyle = result;
            } else if (result == 'bold') {
              env.element.style.fontWeight = result;
            } else {
              env.element.style.textDecoration = result;
            }
          }
          continue;
        }
      

        if (typeof result === 'number') {
        
          env.element.style.fontSize = String(result) + 'pt';
          continue;
        }
      }      
  }

  boxes.DateObjectTemplate = async (args, env) => {
      const element = document.createElement('span');
      element.classList.add(...('sm-controls cursor-default rounded-md 0 py-1 pl-3 bg-gray-100 pr-2 text-left text-gray-500 ring-1 ring-inset ring-gray-400 text-xs'.split(' ')));

      //env.element.classList.add('frame-box');
      env.context = boxes;

      const date = await interpretate(args[0], env);
      element.innerText = date.slice(1,-1); 
      env.element.appendChild(element);
  }

  boxes.RGBColorSwatchTemplate = async (args, env) => {
      const element = document.createElement('span');

      element.classList.add(...('sm-controls cursor-default rounded-md 0 h-4 w-4 shadow-sm'.split(' ')));

      //env.element.classList.add('frame-box');
      env.context = boxes;

      const color = await interpretate(args[0], env);
      element.style.backgroundColor = color;

      env.element.appendChild(element);
  }

  boxes.Opacity = async (args, env) => {
      return (await interpretate(args[0], env));
  }
  
  boxes.RGBColor = async (args, env) => {
      if (args.length == 3) {
        const r = (await interpretate(args[0], env)) * 255;
        const g = (await interpretate(args[1], env)) * 255;
        const b = (await interpretate(args[2], env)) * 255;

        return "rgb("+r+","+g+","+b+")";
      } else {
        let a = await interpretate(args[0], env);

        a = a.map((e) => e*255);

        return "rgb("+a[0]+","+a[1]+","+a[2]+")";
      }

      return undefined;
  }

  boxes.FontWeight = () => 'FontWeight'

  /*boxes.PaneSelectorBox = async (args, env) => {
      const list = await interpretate(args[0], {...env, hold:true});
      //needs an editor View
      env.element.innerText = "EditorView is in development";
      env.element.style.border = "1px solid gray";
      env.element.style.borderRadius = "4px";
  }*/

  boxes.DynamicModuleBox = async (args, env) => {
      return await interpretate(args[1], {...env, context: boxes});
    }
    
    boxes.PaneSelectorBox = async (args, env) => {
      const list = await interpretate(args[0], {...env, hold:true});
      //env.element.innerText = data.slice(1,-1);
      env.element.style.paddingLeft = "0.5em";
      env.element.style.paddingRight = "0.5em";
      env.element.style.borderRadius = "4px";
      env.element.style.border = "1px solid gray";
      env.element.style.verticalAlign = "initial";

      const data = await interpretate(list[0][2], env);

      env.element.innerText = data.flat().join(',').slice(1,-1);
    }

    boxes.CM6Grid = async (args, env) => {
      console.warn('this is an temporal fallback to boxes CM6Grid virtual type! Be careful!');
      const data = await interpretate(args[0], env);
      return data;
    }
    
    boxes.GridBox = async (args, env) => {
      return await interpretate(args[0], env);
    }
    
    boxes.TagBox = async (args, env) => {
      const name = await interpretate(args[1], env);
      const data = await interpretate(args[0], env);
      const doc = document.createElement('div');
      const result = await boxes.TagBox[name](data, {...env, element:doc});
      env.element.appendChild(doc);
      return result;
    }
    
    boxes.TagBox['SummaryItem'] = async (data, env) => {
      env.element.innerText = data.slice(1,-1);
      env.element.style.paddingLeft = "0.5em";
      env.element.style.paddingRight = "0.5em";
      env.element.style.borderRadius = "4px";
      env.element.style.border = "1px solid gray";
      env.element.style.verticalAlign = "initial";
    }


    boxes.BraDecorator = async (args, env) => {
      const pre = document.createElement('span');
      const post = document.createElement('span');
    
      post.innerHTML = "|";
      pre.innerHTML = "&#10216;";
    
      const editor = document.createElement('span');
      env.global.element = editor;
    
      env.element.style.display = "inline-flex";
      env.element.style.alignItems = "baseline";
    
      env.element.appendChild(pre);
      env.element.appendChild(editor);
      env.element.appendChild(post);
    }
    
    boxes.KetDecorator = async (args, env) => {
      const pre = document.createElement('span');
      const post = document.createElement('span');
    
      pre.innerHTML = "|";
      post.innerHTML = "&#10217;";
    
      const editor = document.createElement('span');
      env.global.element = editor;
    
      env.element.style.display = "inline-flex";
      env.element.style.alignItems = "baseline";
    
      env.element.appendChild(pre);
      env.element.appendChild(editor);
      env.element.appendChild(post);
    }

    boxes.FrameMargins = () => "FrameMargins"

    boxes.PanelBox = async (args, env) => {   
      const options = await core._getRules(args, {...env, context: boxes});
      let margin = 0.7; 
      
      if (options.FrameMargins) margin = Math.round(10.0 * options.FrameMargins / 10.0)/10.0;

      const editor = document.createElement('span');
      env.global.element = editor;
    
      env.element.style.display = "inline-flex";
      env.element.style.alignItems = "baseline";
      env.element.style.padding = margin + "em";

      env.element.style.borderRadius = "4px";
      env.element.style.border = "solid 1px";
      env.element.style.background = "#f0f0f0";

      env.element.appendChild(editor); 
      if (options.Event) {
        env.element.addEventListener('click', () => {
          server.kernel.emitt(options.Event, 'True', 'Click')
        })
      }
    }

    boxes["Internal`RawText"] = async (args, env) => {
      const text = await interpretate(args[0], {...env, context: boxes});
      env.element.innerHTML = text;
      env.element.style = "font-family: system-ui"
    }


    boxes.SpanFromLeft = () => "SpanFromLeft"

    boxes.None = () => "None"
    
    boxes["BoxForm`SummaryItemView"] = async (args, env) => {
      const tr = document.createElement('tr');
      const label = document.createElement('td');
      const content = document.createElement('td');

      content.style.maxWidth = "200px";
    
      label.innerText = (await interpretate(args[0], env)).trim();
    
      await interpretate(args[1], {...env, context:boxes, element: content});
    
      tr.appendChild(label);
      tr.appendChild(content);
    
      env.element.appendChild(tr);
    
      
    }

    const quantity = {};

    function isDOM(Obj) { 
              
      // Function that checks whether  
      // object is of type Element 
     return Obj instanceof Element; 
 } 

    boxes.MixedMagnitude = core.List
    quantity.MixedUnit = core.List

    quantity.Power = (args, env) => {
      const string = interpretate(args[0], env);
      const power = interpretate(args[1], env);

      const container = document.createElement('span');
      const sup = document.createElement('sup');
      if (isDOM(string)) {
        container.appendChild(string);
      } else {
        container.innerText = string;
      }

      if (isDOM(string)) {
        sup.appendChild(power);
      } else {
        sup.innerText = power;
      }

      container.appendChild(sup);
      
      return container;
    }

    quantity.Times = (args, env) => {
      const a = args.map((el) => interpretate(el, env));
      const doc = document.createElement('span');

      a.forEach((el, index) => {
        if (isDOM(el)) {
          doc.appendChild(el);
        } else {
          const item = document.createElement('text');
          item.innerText = el;
          doc.appendChild(item);
        } 
        if (index < a.length - 1) {
          const sep = document.createElement('text');
          sep.innerHTML = "&middot;";
          doc.appendChild(sep);
        }
      });

      return doc;
    }

    boxes.QuantityBox = async (args, env) => {
      const n = await interpretate(args[0], env);
      const units = await interpretate(args[1], {...env, context:quantity});

      
      env.element.classList.add(...('text-gray-500 ring-gray-300 ring-1 rounded-lg px-2 text-sm'.split(' ')));
      env.element.style.verticalAlign = 'baseline';

      const add = (nn, nunits, gap = false) => {
        const text = document.createTextNode(nn);
        const u = document.createElement('span');
        u.classList.add('ml-1');
        if (gap) u.classList.add('mr-1');

        if (isDOM(nunits))
          u.appendChild(nunits);
        else
          u.innerText = nunits;
  
        env.element.appendChild(text);
        env.element.appendChild(u);
      }

      //console.error([n, units, args]);
      
      if (Array.isArray(n)) {
        n[0].forEach((number, index) => {
          //console.error({number, index});
          if (index === n[0].length - 1) 
            add(number, units[0][index], false);
          else 
            add(number, units[0][index], true);
        });
      } else {
        add(n, units);
      }


    }

    boxes.ShowStringCharacters = () => "ShowStringCharacters"
    boxes.ShowSpecialCharacters = () => "ShowSpecialCharacters"
    
    boxes.Row = async (args, env) => {
      console.warn('RowBox is not implemented properly for BoxForm`ArrangedSummaryBox!!!');
      args.forEach((el) => {
        interpretate(el, env);
      });
    }
    
    boxes["BoxForm`ArrangedSummaryBox"] = async (args, env) => {
      env.element.style.verticalAlign = 'middle';
      env.element.classList.add(...('sm-controls cursor-default rounded-md 0 py-1 px-2 bg-gray-100 text-left text-gray-500 ring-1 ring-inset ring-gray-400 text-xs flex flex-row'.split(' ')));
    
      let iconElement = document.createElement('span');
      iconElement.classList.add(...('text-gray-500 inline-block mt-auto mb-auto pr-1'.split(' ')));
    
      env.element.appendChild(iconElement);
    
      const table = document.createElement('table');
      table.classList.add(...('pl-1 table-auto'.split(' ')));
      
      let tbodyElement = document.createElement('tbody');
      
      table.appendChild(tbodyElement);
    
      env.element.appendChild(table);
    
      console.log(iconElement.getBoundingClientRect());
    
      const iconWidth = 35 * window.devicePixelRatio;
    
      
    
      interpretate(args[0], {...env, element: iconElement,  global: env.global, imageSize:[iconWidth, iconWidth]});
      await interpretate(args[1], {...env, context: boxes, element: tbodyElement, static:true, local: false});

      if (env.options) {
        if (env.options.DataOnKernel) {
          const warn = document.createElement('span');
          warn.innerText = "Data is on Kernel";
          warn.classList.add('text-gray-400');
        
          tbodyElement.appendChild(warn);
        }
      }
    }




    //temporaly here
