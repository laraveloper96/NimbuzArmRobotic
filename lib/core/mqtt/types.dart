enum Topic {
  human('human/register/robot'),
  move('robot/movement'),
  speed('robot/speed');

  const Topic(this.url);

  final String url;
}
