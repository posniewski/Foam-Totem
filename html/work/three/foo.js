
var container = document.createElement( 'div' ),
width = 1920,
height = 1019,
camera,
scene,
renderer,
SHADOW_MAP_WIDTH = 2048,
SHADOW_MAP_HEIGHT = 1024;

container = document.body.appendChild( container );

camera = new THREE.PerspectiveCamera( 50, 1, 1, 5000 );
camera.position.set(500,250,500);
camera.rotation.set(-0.4636476090008061,0.7297276562269663,0.3217505543966422);
camera.aspect = width / height;
camera.updateProjectionMatrix();

scene = new THREE.Scene();

renderer = new THREE.WebGLRenderer( { clearAlpha: 1, clearColor: 0x808080 } );
renderer.setSize( width, height );
renderer.shadowCameraNear = 3;
renderer.shadowCameraFar = this.camera.far;
renderer.shadowCameraFov = 50;
renderer.shadowMapBias = 0.0039;
renderer.shadowMapDarkness = 0.5;
renderer.shadowMapWidth = SHADOW_MAP_WIDTH;
renderer.shadowMapHeight = SHADOW_MAP_HEIGHT;
renderer.shadowMapEnabled = true;
renderer.shadowMapSoft = true;
container.appendChild( renderer.domElement );

var geometry = new THREE.CubeGeometry( 100,100,100,1,1,1 );
var material = new THREE.MeshPhongMaterial();
material.color = new THREE.Color().setRGB(1,1,1);
material.ambient = new THREE.Color().setRGB(0.0196078431372549,0.0196078431372549,0.0196078431372549);
material.specular = new THREE.Color().setRGB(0.06666666666666667,0.06666666666666667,0.06666666666666667);

var mesh = new THREE.Mesh(geometry, material);
mesh.position.set(0,0,0);
mesh.rotation.set(0,0,0);
mesh.scale.set(1,1,1);
scene.add( mesh );
});

var mesh = new THREE.PointLight();
mesh.intensity = 1;
mesh.castShadow = false;
mesh.color = new THREE.Color().setRGB(1,1,1);
mesh.position.set(100,150,0);
mesh.rotation.set(0,0,0);
mesh.scale.set(1,1,1);
scene.add( mesh );

var loader = new THREE.JSONLoader();
loader.load( "/work/three/luxo.js", function(geometry) {
	var material = new THREE.MeshPhongMaterial();
	material.color = new THREE.Color().setRGB(1,1,1);
	material.ambient = new THREE.Color().setRGB(0.0196078431372549,0.0196078431372549,0.0196078431372549);
	material.specular = new THREE.Color().setRGB(0.06666666666666667,0.06666666666666667,0.06666666666666667);
	material.map = THREE.ImageUtils.loadTexture("path/to/texture.jpg");

	material.morphTargets = true;
	var mesh = new THREE.Mesh(geometry, material);
	mesh.position.set(0,0,0);
	mesh.rotation.set(0,0,0);
	mesh.scale.set(1,1,1);
	scene.add( mesh );
});

function animate() {
	requestAnimationFrame( animate );
	renderer.render( scene, camera );
}

animate();

