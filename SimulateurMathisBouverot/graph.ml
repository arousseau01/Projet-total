exception Cycle
type mark = NotVisited | InProgress | Visited

type 'a graph =
    { mutable g_nodes : 'a node list }
and 'a node = {
  n_label : 'a;
  mutable n_mark : mark;
  mutable n_link_to : 'a node list;
  mutable n_linked_by : 'a node list;
}

let mk_graph () = { g_nodes = [] }

let add_node g x =
  let n = { n_label = x; n_mark = NotVisited; n_link_to = []; n_linked_by = [] } in
  g.g_nodes <- n::g.g_nodes

let node_for_label g x =
  List.find (fun n -> n.n_label = x) g.g_nodes

let add_edge g id1 id2 =
  let n1 = node_for_label g id1 in
  let n2 = node_for_label g id2 in
  n1.n_link_to <- n2::n1.n_link_to;
  n2.n_linked_by <- n1::n2.n_linked_by

let clear_marks g =
  List.iter (fun n -> n.n_mark <- NotVisited) g.g_nodes

let find_roots g =
  List.filter (fun n -> n.n_linked_by = []) g.g_nodes

let has_cycle g =
  let cyc = ref false in
  clear_marks g;
  let rec dfs n = match n.n_mark with
 	  | InProgress -> cyc := true
	  | Visited -> ()
	  | NotVisited -> begin
		  n.n_mark <- InProgress; 
		  List.iter dfs n.n_link_to;
		  n.n_mark <- Visited
	  end
  in
	List.iter dfs g.g_nodes;
	!cyc

let topological g =
  if has_cycle g then raise Cycle else
  clear_marks g;
  let order = ref [] in
  let rec dfs n =
    match n.n_mark with
      | NotVisited -> begin
        List.iter dfs n.n_link_to;
        n.n_mark <- Visited;
        order := n.n_label :: !order
      end
      | _ -> ()
  in
	List.iter dfs g.g_nodes;
	!order
